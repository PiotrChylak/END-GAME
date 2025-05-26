// Decision-based Text Novel Game Contract - Actions (in systems)
// Contains all logic and helper functions for the text novel game.
use stwo_the_end::models::{
    PlayerState, NodeMeta, Choice, PlayerDecision, Decision, StoryCompleted, GamblingLevelConfig,
    Chances, Multiplier, GamblingOutcome, InvalidChoice
};
use origami_random::dice::{DiceTrait};

#[starknet::interface]
pub trait ITextNovelGame<T> {
    fn start_new_game(ref self: T);
    fn make_decision(ref self: T, choice: u8) -> u16;
    fn get_current_node(self: @T) -> u16;
    //fn gamble(ref self: T, choice: u8) -> felt252; //Have to make some changes in NodeMeta model
//if i dont want to make separate function (node id's mod5 -> gamble node??)
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

    #[abi(embed_v0)]
    impl GameImpl of ITextNovelGame<ContractState> {
        fn start_new_game(ref self: ContractState) {
            let mut world = self.world_default();
            let player = get_caller_address();
    
            // Story nodes with shorter text
            world.write_model(@NodeMeta{ id: 1, text: 'starting node', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 1, choice_id: 1, text: 'go to 11', next_node: 11 });
            world.write_model(@Choice { node_id: 1, choice_id: 2, text: 'go to 12', next_node: 12 });

            world.write_model(@NodeMeta{ id: 11, text: 'node 11', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 11, choice_id: 1, text: 'go to 111', next_node: 111 });
            world.write_model(@Choice { node_id: 11, choice_id: 2, text: 'go to 121', next_node: 121 });

            world.write_model(@NodeMeta{ id: 12, text: 'node 12', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 12, choice_id: 1, text: 'go to 121', next_node: 121 });
            world.write_model(@Choice { node_id: 12, choice_id: 2, text: 'go to 122', next_node: 122 });

            world.write_model(@NodeMeta{ id: 111, text: 'node 111', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 111, choice_id: 1, text: 'go gamble 5', next_node: 5 });

            world.write_model(@NodeMeta{ id: 112, text: 'node 112', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 112, choice_id: 1, text: 'go gamble 10', next_node: 10 });

            world.write_model(@NodeMeta{ id: 121, text: 'node 121', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 121, choice_id: 1, text: 'go gamble 15', next_node: 15 });

            world.write_model(@NodeMeta{ id: 122, text: 'node 122', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 122, choice_id: 1, text: 'go gamble 20', next_node: 20 });

            world.write_model(@NodeMeta{ id: 5, text: 'gambling node 1_1 (5)', gambling_node: true ,is_ending: false });
            world.write_model(@Choice { node_id: 5, choice_id: 1, text: 'Gamble (5)', next_node: 1111 });
            world.write_model(@Choice { node_id: 5, choice_id: 2, text: 'Skip (5)', next_node: 1111 });

            world.write_model(@NodeMeta{ id: 10, text: 'gambling node 1_2 (10)', gambling_node: true ,is_ending: false });
            world.write_model(@Choice { node_id: 10, choice_id: 1, text: 'Gamble (10)', next_node: 1121 });
            world.write_model(@Choice { node_id: 10, choice_id: 2, text: 'Skip (10)', next_node: 1121 });

            world.write_model(@NodeMeta{ id: 15, text: 'gambling node 1_3 (15)', gambling_node: true ,is_ending: false });
            world.write_model(@Choice { node_id: 15, choice_id: 1, text: 'Gamble (15)', next_node: 1211 });
            world.write_model(@Choice { node_id: 15, choice_id: 2, text: 'Skip (15)', next_node: 1211 });

            world.write_model(@NodeMeta{ id: 20, text: 'gambling node 1_4 (20)', gambling_node: true ,is_ending: false });
            world.write_model(@Choice { node_id: 20, choice_id: 1, text: 'Gamble (20)', next_node: 1221 });
            world.write_model(@Choice { node_id: 20, choice_id: 2, text: 'Skip (20)', next_node: 1221 });

            world.write_model(@NodeMeta{ id: 1111, text: 'node 1111', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 1111, choice_id: 1, text: 'go to 11111', next_node: 11111 });
            world.write_model(@Choice { node_id: 1111, choice_id: 2, text: 'go to 11112', next_node: 11112 });

            world.write_model(@NodeMeta{ id: 1121, text: 'node 1121', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 1121, choice_id: 1, text: 'go to 11211', next_node: 11211 });
            world.write_model(@Choice { node_id: 1121, choice_id: 2, text: 'go to 11212', next_node: 11212 });

            world.write_model(@NodeMeta{ id: 1211, text: 'node 1211', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 1211, choice_id: 1, text: 'go to 12111', next_node: 12111 });
            world.write_model(@Choice { node_id: 1211, choice_id: 2, text: 'go to 12112', next_node: 12112 });

            world.write_model(@NodeMeta{ id: 1221, text: 'node 1221', gambling_node: false ,is_ending: false });
            world.write_model(@Choice { node_id: 1221, choice_id: 1, text: 'go to 12211', next_node: 12211 });
            world.write_model(@Choice { node_id: 1221, choice_id: 2, text: 'go to 12212', next_node: 12212 });

            world.write_model(@NodeMeta{ id: 11111, text: 'final node 11111', gambling_node: false ,is_ending: true });
            world.write_model(@NodeMeta{ id: 11112, text: 'final node 11112', gambling_node: false ,is_ending: true });
            world.write_model(@NodeMeta{ id: 11211, text: 'final node 11211', gambling_node: false ,is_ending: true });
            world.write_model(@NodeMeta{ id: 11212, text: 'final node 11212', gambling_node: false ,is_ending: true });
            world.write_model(@NodeMeta{ id: 12111, text: 'final node 12111', gambling_node: false ,is_ending: true });
            world.write_model(@NodeMeta{ id: 12112, text: 'final node 12112', gambling_node: false ,is_ending: true });
            world.write_model(@NodeMeta{ id: 12211, text: 'final node 12211', gambling_node: false ,is_ending: true });
            world.write_model(@NodeMeta{ id: 12212, text: 'final node 12212', gambling_node: false ,is_ending: true });
    
            // Initialize player state
            world.write_model(@PlayerState { player, balance: 100, current_node: 1, story_completed: false});
    
            // Initialize gambling config
            let config = get_level_config(0);
            world.write_model(@GamblingLevelConfig { player: player, level: config.level, multiplier: config.multiplier, chances: config.chances});
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
                world.emit_event(@InvalidChoice { node_id: node.id, text: 'Invalid choice for this node', choice: choice_struct.choice_id});
                return state.current_node;
            }
            
            world.write_model(@PlayerDecision { player, node_id: state.current_node, choice });

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
                let next_level = (current_config.level + 1) % 5;
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

pub fn get_level_config(level: u8) -> StaticGamblingConfig {
    match level {
        0 => StaticGamblingConfig { level: 1, multiplier: Multiplier::Low, chances: Chances::High },
        1 => StaticGamblingConfig { level: 2, multiplier: Multiplier::Mid, chances: Chances::Mid },
        2 => StaticGamblingConfig { level: 3, multiplier: Multiplier::High, chances: Chances::Low },
        3 => StaticGamblingConfig { level: 4, multiplier: Multiplier::Huge, chances: Chances::Little },
        4 => StaticGamblingConfig { level: 5, multiplier: Multiplier::Huge, chances: Chances::Little },
        _ => StaticGamblingConfig { level: 6, multiplier: Multiplier::Mid, chances: Chances::Low },
    }
}
