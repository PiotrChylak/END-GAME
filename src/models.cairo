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

