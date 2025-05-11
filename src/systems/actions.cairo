// Decision-based Text Novel Game Contract - Actions (in systems)
// Contains all logic and helper functions for the text novel game.

use stwo_the_end::models::{PlayerState, StoryNodeMeta, Choice, PlayerDecision, Decision, StoryCompleted};
use starknet::get_caller_address;

#[starknet::interface]
trait ITextNovelGame<TContractState> {
    fn start_new_game(ref self: TContractState);
    fn make_decision(ref self: TContractState, choice: u8) -> u16;
    fn get_current_node(self: @TContractState) -> u16;
    fn is_story_completed(self: @TContractState) -> bool;
    fn get_node_meta(self: @TContractState, node_id: u16) -> StoryNodeMeta;
    fn get_choice(self: @TContractState, node_id: u16, choice_id: u8) -> Choice;
}

#[dojo::contract]
mod actions {
    use super::*;

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[abi(embed_v0)]
    impl GameImpl of ITextNovelGame<ContractState> {
        fn start_new_game(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();
            world.write_model(@PlayerState { player, current_node: 1, story_completed: false });
        }

        fn make_decision(ref self: ContractState, choice: u8) -> u16 {
            let mut world = self.world_default();
            let player = get_caller_address();
            let mut state: PlayerState = world.read_model(player);
            let choice_struct: Choice = world.read_model((state.current_node, choice));
            let next_node = choice_struct.next_node;
            world.write_model(@PlayerDecision { player, node_id: state.current_node, choice });
            state.current_node = next_node;
            let node_meta: StoryNodeMeta = world.read_model(next_node);
            if node_meta.is_ending {
                state.story_completed = true;
                world.emit_event(@StoryCompleted { player, final_node: next_node });
            }
            world.emit_event(@Decision { player, node_id: state.current_node, choice, next_node });
            world.write_model(@state);
            next_node
        }

        fn get_current_node(self: @ContractState) -> u16 {
            let world = self.world_default();
            let player = get_caller_address();
            let state: PlayerState = world.read_model(player);
            state.current_node
        }

        fn is_story_completed(self: @ContractState) -> bool {
            let world = self.world_default();
            let player = get_caller_address();
            let state: PlayerState = world.read_model(player);
            state.story_completed
        }

        fn get_node_meta(self: @ContractState, node_id: u16) -> StoryNodeMeta {
            let world = self.world_default();
            world.read_model(node_id)
        }

        fn get_choice(self: @ContractState, node_id: u16, choice_id: u8) -> Choice {
            let world = self.world_default();
            world.read_model((node_id, choice_id))
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        /// Use the default namespace "dojo_starter". This function is handy since the ByteArray
        /// can't be const.
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"stwo_the_end")
        }
    }
}