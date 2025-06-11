#[cfg(test)]
mod tests {
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage};
    use dojo::world::WorldStorageTrait;
    use dojo_cairo_test::{
        spawn_test_world, NamespaceDef, TestResource, ContractDefTrait, ContractDef,
    };
    use stwo_the_end::models::{
        PlayerState, m_PlayerState, PlayerDecision, m_PlayerDecision, NodeMeta, m_NodeMeta, Choice, m_Choice, GamblingLevelConfig, m_GamblingLevelConfig, Multiplier, Chances
    };
    use stwo_the_end::systems::actions::{
        actions, ITextNovelGameDispatcher, ITextNovelGameDispatcherTrait
    };
    use origami_random::dice::{DiceTrait};
    use starknet::ContractAddress;
    use core::integer::u256;
    use stwo_the_end::systems::token_dispatcher::Token::ITokenDispatcher;
    use stwo_the_end::systems::token_dispatcher::ITokenDispatcherTrait;
    use stwo_the_end::events::{Decision, StoryCompleted, GamblingOutcome, InvalidChoice, e_Decision, e_StoryCompleted, e_GamblingOutcome, e_InvalidChoice};
    
    fn namespace_def() -> NamespaceDef {
        let ndef = NamespaceDef {
            namespace: "StwoTheEnd",
            resources: [
                TestResource::Model(m_PlayerState::TEST_CLASS_HASH),
                TestResource::Model(m_PlayerDecision::TEST_CLASS_HASH),
                TestResource::Model(m_NodeMeta::TEST_CLASS_HASH),
                TestResource::Model(m_Choice::TEST_CLASS_HASH),
                TestResource::Model(m_GamblingLevelConfig::TEST_CLASS_HASH),
                TestResource::Contract(actions::TEST_CLASS_HASH),
                TestResource::Event(e_Decision::TEST_CLASS_HASH),
                TestResource::Event(e_StoryCompleted::TEST_CLASS_HASH),
                TestResource::Event(e_GamblingOutcome::TEST_CLASS_HASH),
                TestResource::Event(e_InvalidChoice::TEST_CLASS_HASH),
            ]
                .span(),
        };
        ndef
    }


    fn contract_defs() -> Span<ContractDef> {
        [
            ContractDefTrait::new(@"StwoTheEnd", @"actions")
                .with_writer_of([dojo::utils::bytearray_hash(@"StwoTheEnd")].span())
        ].span()
    }

    #[test]
    fn test_initalize_game() {
        let caller = starknet::contract_address_const::<0x0>();
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let game = ITextNovelGameDispatcher { contract_address };

        let dummy_token_address = starknet::contract_address_const::<0x1234>();
        game.start_new_game(dummy_token_address);
        let state: PlayerState = world.read_model(caller);
        assert(state.current_node == 1, 'Initial node is 1');
        assert(state.balance == 1000000000000000000, 'Initial balance is 10 ** 18');
    }

    #[test]
    fn test_make_decision_valid() {
        let caller = starknet::contract_address_const::<0x0>();
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let game = ITextNovelGameDispatcher { contract_address };

        let dummy_token_address = starknet::contract_address_const::<0x1234>();
        game.start_new_game(dummy_token_address);

        world.write_model(@NodeMeta { id: 1, text: 'Start', gambling_node: false, is_ending: false });
        world.write_model(@Choice { node_id: 1, choice_id: 0, text: 'Go to node 2', next_node: 2 });
        world.write_model(@NodeMeta { id: 2, text: 'Next node', gambling_node: false, is_ending: false });

        let new_node = game.make_decision(0);
        let state: PlayerState = world.read_model(caller);

        assert(new_node == 2, 'Move to node 2');
        assert(state.current_node == 2, 'Current node is 2');

        let player_decision: PlayerDecision = world.read_model((caller, 1));
        assert(player_decision.choice == 0, 'Choice is 0');
    }

    #[test]
    fn test_make_decision_invalid() {
        let caller = starknet::contract_address_const::<0x0>();
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let game = ITextNovelGameDispatcher { contract_address };

        let dummy_token_address = starknet::contract_address_const::<0x1234>();
        game.start_new_game(dummy_token_address);

        world.write_model(@NodeMeta { id: 1, text: 'Start', gambling_node: false, is_ending: false });
        world.write_model(@Choice { node_id: 1, choice_id: 0, text: 'Go to node 2', next_node: 2 });

        let mut state: PlayerState = world.read_model(caller);

        let current_node_before = state.current_node;
        let returned_node = game.make_decision(99); // Invalid choice
        let current_node_after: PlayerState = world.read_model(caller);

        assert(returned_node == current_node_before, 'Return current node');
        assert(current_node_after.current_node == current_node_before, 'Node not changed');
    }

    #[test]
    fn test_gambling() {
        let caller = starknet::contract_address_const::<0x0>();
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let game = ITextNovelGameDispatcher { contract_address };

        let dummy_token_address = starknet::contract_address_const::<0x1234>();
        game.start_new_game(dummy_token_address);

        // Set up a gambling node where choice 1 leads to gambling
        world.write_model(@NodeMeta { id: 1, text: 'Gambling node', gambling_node: true, is_ending: false });
        world.write_model(@Choice { node_id: 1, choice_id: 1, text: 'Gamble', next_node: 2 });
        world.write_model(@NodeMeta { id: 2, text: 'After gamble', gambling_node: false, is_ending: false });

        let mut state: PlayerState = world.read_model(caller);
        let initial_balance = state.balance;

        game.make_decision(1); // Make decision to gamble
        let new_state: PlayerState = world.read_model(caller);
        let state_after_gamble = new_state.balance;

        assert(initial_balance != state_after_gamble, 'Balance should change');
        assert(new_state.current_node == 2, 'Moved to node 2');
    }

}
