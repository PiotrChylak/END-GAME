// Decision-based Text Novel Game Contract - Models (Scalable Structure)
// Contains only storage, events, enums, and interface definitions.

use starknet::ContractAddress;

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct PlayerState {
    #[key]
    pub player: ContractAddress,
    pub balance: felt252,
    pub current_node: u16,
    pub story_completed: bool,
}

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct PlayerDecision {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub node_id: u16,
    pub choice: u8,
}

#[derive(Drop, Serde, Introspect, Copy)]
#[dojo::model]
pub struct NodeMeta {
    #[key]
    pub id: u16,
    pub text: felt252,
    pub gambling_node: bool,
    pub is_ending: bool,
}

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct Choice {
    #[key]
    pub node_id: u16,
    #[key]
    pub choice_id: u8,
    pub text: felt252,
    pub next_node: u16,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct Decision {
    #[key]
    pub player: ContractAddress,
    pub node_id: u16,
    pub choice: u8,
    pub next_node: u16,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct StoryCompleted {
    #[key]
    pub player: ContractAddress,
    pub final_node: u16,
}

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct GamblingLevelConfig {
    #[key]
    pub player: ContractAddress,
    pub level: u8,
    pub multiplier: Multiplier,
    pub chances: Chances,
}

# [derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum Multiplier {
    Little,
    Low,
    Mid,
    High,
    Huge,
}

# [derive(Serde, Copy, Drop, Introspect, PartialEq)]
pub enum Chances {
    Huge,
    High,
    Mid,
    Low,
    Little,
}

#[derive(Drop, Serde, Copy)]
#[dojo::event]
pub struct InvalidChoice{
    #[key]
    pub node_id: u16,
    pub text: felt252,
    pub choice: u8,
}

#[derive(Drop, Serde)]
#[dojo::event]
pub struct GamblingOutcome {
    #[key]
    pub player: ContractAddress,
    pub profit: felt252,
    pub new_balance: felt252,
}

impl MultiplierFelt252 of Into<Multiplier, felt252> {
 
   fn into(self: Multiplier) -> felt252 {
       match self {
           Multiplier::Little => 2,
           Multiplier::Low => 3,
           Multiplier::Mid => 4,
           Multiplier::High => 5,
           Multiplier::Huge => 7,
       }
   }
}

impl ChancesU8 of Into<Chances, u8> {

    fn into(self: Chances) -> u8 {
        match self {
            Chances::Huge => 2,
            Chances::High => 3,
            Chances::Mid => 4,
            Chances::Low => 6,
            Chances::Little => 7,
        }
    }
}
