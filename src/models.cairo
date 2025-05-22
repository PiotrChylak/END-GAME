// Decision-based Text Novel Game Contract - Models (Scalable Structure)
// Contains only storage, events, enums, and interface definitions.

use starknet::ContractAddress;

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct PlayerState {
    #[key]
    pub player: ContractAddress,
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

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct StoryNodeMeta {
    #[key]
    pub id: u16,
    pub text: felt252,
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
    pub level: felt252,
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

impl Multiplierx10_felt252 of Into<Multiplier, felt252> {
 
   fn into(self: Multiplier) -> felt252 {
       match self {
           Multiplier::Little => 11,
           Multiplier::Low => 13,
           Multiplier::Mid => 15,
           Multiplier::High => 20,
           Multiplier::Huge => 30,
       }
   }
}

impl Chancesx100_felt252 of Into<Chances, felt252> {

    fn into(self: Chances) -> felt252 {
        match self {
            Chances::Huge => 90,
            Chances::High => 70,
            Chances::Mid => 45,
            Chances::Low => 15,
            Chances::Little => 5,
        }
    }
}

