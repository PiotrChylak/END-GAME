#[cfg(test)]
mod tests {
    use dojo_cairo_test::WorldStorageTestTrait;
    use dojo::model::{ModelStorage, ModelValueStorage, ModelValueStorageTest};
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
    fn test_game_flow() {
        let caller = starknet::contract_address_const::<0x0>();
        let ndef = namespace_def();
        let mut world = spawn_test_world([ndef].span());
        world.sync_perms_and_inits(contract_defs());

        let (contract_address, _) = world.dns(@"actions").unwrap();
        let game = ITextNovelGameDispatcher { contract_address };

        // Start a new game
        game.start_new_game();
        let state: PlayerState = world.read_model(caller);
        assert(state.current_node == 1, 'Initial node should be 1');
        assert(state.balance == 100, 'Initial balance should be 100');
    }
}
