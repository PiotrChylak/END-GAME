// Decision-based Text Novel Game Contract - Actions (in systems)
// Contains all logic and helper functions for the text novel game.
use stwo_the_end::models::{PlayerState, NodeMeta, Choice, PlayerDecision, Decision, StoryCompleted, GamblingLevelConfig, Chances, Multiplier};
use origami_random::dice::{DiceTrait};

#[starknet::interface]
trait ITextNovelGame<T> {
    fn start_new_game(ref self: T);
    fn make_decision(ref self: T, choice: u8) -> u16;
    //fn gamble(ref self: T, choice: u8) -> felt252; //Have to make some changes in NodeMeta model if i dont want to make separate function (node id's mod5 -> gamble node??)
}

#[dojo::contract]
mod actions {
    use super::{ITextNovelGame, PlayerState, NodeMeta, Choice, PlayerDecision, Decision, StoryCompleted, GamblingLevelConfig, get_level_config};
    use starknet::{get_caller_address};

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;

    #[abi(embed_v0)]
    impl GameImpl of ITextNovelGame<ContractState> {
        fn start_new_game(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();
            
            world.write_model(@NodeMeta{ id: 1, text: 'You wake up in a forest.', is_ending: false });
            world.write_model(@NodeMeta { id: 11, text: 'You find a river.', is_ending: true });
            world.write_model(@NodeMeta { id: 12, text: 'You meet a wolf.', is_ending: true });
            world.write_model(@Choice { node_id: 1, choice_id: 1, text: 'Go left', next_node: 11 });
            world.write_model(@Choice { node_id: 1, choice_id: 2, text: 'Go right', next_node: 12 });
            world.write_model(@PlayerState { player, balance: 100, current_node: 1, story_completed: false});
            
            let config = get_level_config(0);
            world.write_model(@GamblingLevelConfig { player: player, level: config.level, multiplier: config.multiplier, chances: config.chances});
        }

        fn make_decision(ref self: ContractState, choice: u8) -> u16 {
            let mut world = self.world_default();
            let player = get_caller_address();
            let mut state: PlayerState = world.read_model(player);
            let choice_struct: Choice = world.read_model((state.current_node, choice));
            let next_node = choice_struct.next_node;
            world.write_model(@PlayerDecision { player, node_id: state.current_node, choice });
            state.current_node = next_node;
            let node_meta: NodeMeta = world.read_model(next_node);
            if node_meta.is_ending {
                state.story_completed = true;
                world.emit_event(@StoryCompleted { player, final_node: next_node });
            }
            world.emit_event(@Decision { player, node_id: state.current_node, choice, next_node });
            world.write_model(@state);
            next_node
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn world_default(self: @ContractState) -> dojo::world::WorldStorage {
            self.world(@"StwoTheEnd")
        }
    }
}

fn calculate_outcome(mut balance: felt252, chances: Chances, multipliers: Multiplier) -> felt252 {
    let chance = chances.into();
    let multiplier: felt252 = multipliers.into();
    let mut dice = DiceTrait::new(chance, 'SEED');

    let result = dice.roll();
     if result == 1 {
         balance *= multiplier
     } else {
         balance == 0;
     }
    balance
}

struct StaticGamblingConfig {
    level: felt252,
    multiplier: Multiplier,
    chances: Chances,
}

fn get_level_config(level: felt252) -> StaticGamblingConfig {
    match level {
        0 => StaticGamblingConfig {
            level: 1,
            multiplier: Multiplier::Low,
            chances: Chances::High,
        },
        1 => StaticGamblingConfig{
            level: 2,
            multiplier: Multiplier::Mid,
            chances: Chances::Mid,
        },
        2 => StaticGamblingConfig {
            level: 3,
            multiplier: Multiplier::High,
            chances: Chances::Low,
        },
        3 => StaticGamblingConfig {
            level: 4,
            multiplier: Multiplier::Huge,
            chances: Chances::Little,
        },
        4 => StaticGamblingConfig {
            level: 5,
            multiplier: Multiplier::Huge,
            chances: Chances::Little,
        },
        _ => StaticGamblingConfig {
            level: 6,
            multiplier: Multiplier::Mid,
            chances: Chances::Low,
        }
    }
}
