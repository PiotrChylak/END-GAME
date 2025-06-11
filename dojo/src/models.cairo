// Decision-based Text Novel Game Contract - Models
// Contains only storage, enums etc.

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

#[derive(Drop, Serde, Introspect, Copy)]
#[dojo::model]
pub struct GamblingLevelConfig {
    #[key]
    pub player: ContractAddress,
    pub token: ContractAddress,
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

#[cfg(test)]
mod tests {
    use super::{Choice, Multiplier, Chances, MultiplierFelt252, ChancesU8};

    #[test]
    fn test_multiplier_into_felt252() {
        assert(MultiplierFelt252::into(Multiplier::Huge) == 7, 'Huge multiplier should be 7');
        assert(MultiplierFelt252::into(Multiplier::Low) == 3, 'Low multiplier should be 3');
    }

    #[test]
    fn test_chances_into_u8() {
        assert(ChancesU8::into(Chances::Huge) == 2, 'Huge chance should be 2');
        assert(ChancesU8::into(Chances::Little) == 7, 'Little chance should be 7');
    }

    #[test]
    fn test_choice_struct() {
        let choice = Choice { node_id: 1, choice_id: 2, text: 'Go right', next_node: 12 };
        assert(choice.next_node == 12, 'Choice next_node should be 12');
    }
}
