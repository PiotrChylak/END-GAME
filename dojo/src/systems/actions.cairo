// Decision-based Text Novel Game Contract - Actions (in systems)
// Contains all logic and helper functions for the text novel game.
use stwo_the_end::models::{PlayerState, NodeMeta, Choice, PlayerDecision, GamblingLevelConfig,Chances, Multiplier};
use stwo_the_end::events::{Decision, StoryCompleted, GamblingOutcome, InvalidChoice};
use super::tree_constructor::tree_constructor;

use origami_random::dice::{DiceTrait};
//use core::integer::u256;

// Import the token dispatcher trait
use super::token_dispatcher::ITokenDispatcherDispatcherTrait;

#[starknet::interface]
pub trait ITextNovelGame<T> {
    fn start_new_game(ref self: T);
    fn make_decision(ref self: T, choice: u8) -> u16;
    fn get_current_node(self: @T) -> u16;
    // fn deposit(ref self: T, to: ContractAddress, amount: u256);
}

#[dojo::contract]
pub mod actions {
    use super::{
        ITextNovelGame, PlayerState, NodeMeta, Choice, PlayerDecision, Decision, StoryCompleted,
        GamblingLevelConfig, GamblingOutcome, InvalidChoice, get_level_config, calculate_outcome
    };
    use starknet::{get_caller_address};

    use dojo::model::{ModelStorage};
    use dojo::event::EventStorage;
    use super::tree_constructor;
    // use starknet::syscalls::call_contract_syscall;

    #[abi(embed_v0)]
    impl GameImpl of ITextNovelGame<ContractState> {
        fn start_new_game(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();

            // Initialize the story tree
            tree_constructor(world);

            // Initialize player state
            world.write_model(@PlayerState { 
                player, 
                balance: 100, 
                current_node: 1, 
                story_completed: false
            });

            // Initialize gambling config
            let config = get_level_config(0);
            world.write_model(@GamblingLevelConfig { 
                player: player, 
                level: config.level, 
                multiplier: config.multiplier, 
                chances: config.chances
            });
        }

        fn make_decision(ref self: ContractState, choice: u8) -> u16 {
            let mut world = self.world_default();
            let player = get_caller_address();
            let mut state: PlayerState = world.read_model(player);
            let node: NodeMeta = world.read_model(state.current_node);
            let choice_struct: Choice = world.read_model((state.current_node, choice));
            let next_node = choice_struct.next_node;
            
            // If next_node is 0, treat as invalid choice and return current node
            if next_node == 0{
                world.emit_event(@InvalidChoice { 
                    node_id: node.id, 
                    text: 'Invalid choice for this node', 
                    choice: choice_struct.choice_id
                });
                return state.current_node;
            }
            
            world.write_model(@PlayerDecision { 
                player, 
                node_id: state.current_node, 
                choice 
            });

            // Check if current node is a gambling node
            if node.gambling_node == true {
                // If player chose to gamble (choice 1)
                if choice == 1 {
                    let config: GamblingLevelConfig = world.read_model(player);
                    let outcome = calculate_outcome(
                        state.balance, config.chances, config.multiplier,
                    );
                    state.balance = outcome;
                    world.emit_event(
                        @GamblingOutcome {
                                player,
                                profit: outcome - state.balance,
                                new_balance: outcome,
                            },
                        );
                }

                // Update gambling level config regardless of choice
                let current_config: GamblingLevelConfig = world.read_model(player);
                let next_level = (current_config.level + 1) % 4;
                let new_config = get_level_config(next_level);
                world
                    .write_model(
                        @GamblingLevelConfig {
                            player,
                            level: new_config.level,
                            multiplier: new_config.multiplier,
                            chances: new_config.chances,
                        },
                    );
            }

            state.current_node = next_node;
            let node_meta: NodeMeta = world.read_model(next_node);
            if node_meta.is_ending {
                state.story_completed = true;
                world.emit_event(@StoryCompleted { player, final_node: next_node });
                // Game finished: send new balance to player
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
    level: u8,
    multiplier: Multiplier,
    chances: Chances,
}

fn get_level_config(level: u8) -> StaticGamblingConfig {
    match level {
        0 => StaticGamblingConfig { level: 1, multiplier: Multiplier::Low, chances: Chances::High },
        1 => StaticGamblingConfig { level: 2, multiplier: Multiplier::Mid, chances: Chances::Mid },
        2 => StaticGamblingConfig { level: 3, multiplier: Multiplier::High, chances: Chances::Low },
        3 => StaticGamblingConfig { level: 4, multiplier: Multiplier::Huge, chances: Chances::Little },
        _ => StaticGamblingConfig { level: 5, multiplier: Multiplier::Mid, chances: Chances::Low },
    }
}

