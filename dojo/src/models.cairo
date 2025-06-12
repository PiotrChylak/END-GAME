// Decision-based Text Novel Game Contract - Models
// Contains only storage, enums etc.

use starknet::ContractAddress;

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct PlayerState {
    #[key]
    pub player: ContractAddress,
    pub balance: felt252,
    pub current_node: u32,
    pub story_completed: bool,
}

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct PlayerDecision {
    #[key]
    pub player: ContractAddress,
    #[key]
    pub node_id: u32,
    pub choice: u8,
}

#[derive(Drop, Serde, Introspect, Copy)]
#[dojo::model]
pub struct NodeMeta {
    #[key]
    pub id: u32,
    pub text: felt252,
    pub gambling_node: bool,
    pub is_ending: bool,
}

#[derive(Drop, Serde, Introspect)]
#[dojo::model]
pub struct Choice {
    #[key]
    pub node_id: u32,
    #[key]
    pub choice_id: u8,
    pub text: felt252,
    pub next_node: u32,
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
            Chances::Little => 9,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::{
        Choice,
        Multiplier,
        Chances,
        MultiplierFelt252,
        ChancesU8,
        PlayerState,
        PlayerDecision,
        NodeMeta,
        GamblingLevelConfig,
    };

    #[test]
    #[available_gas(1000000)]
    fn test_multiplier_into_felt252() {
        assert(MultiplierFelt252::into(Multiplier::Little) == 2, 'Little multiplier should be 2');
        assert(MultiplierFelt252::into(Multiplier::Low) == 3, 'Low multiplier should be 3');
        assert(MultiplierFelt252::into(Multiplier::Mid) == 4, 'Mid multiplier should be 4');
        assert(MultiplierFelt252::into(Multiplier::High) == 5, 'High multiplier should be 5');
        assert(MultiplierFelt252::into(Multiplier::Huge) == 7, 'Huge multiplier should be 7');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_chances_into_u8() {
        assert(ChancesU8::into(Chances::Huge) == 2, 'Huge chance should be 2');
        assert(ChancesU8::into(Chances::Mid) == 4, 'Mid chance should be 4');
        assert(ChancesU8::into(Chances::High) == 3, 'High chance should be 3');
        assert(ChancesU8::into(Chances::Low) == 6, 'Low chance should be 6');
        assert(ChancesU8::into(Chances::Little) == 9, 'Little chance should be 7');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_choice_struct() {
        let choice = Choice { node_id: 1, choice_id: 2, text: 'Go right', next_node: 12 };
        assert(choice.next_node == 12, 'Choice next_node should be 12');
        assert(choice.node_id == 1, 'Choice node_id should be 1');
        assert(choice.choice_id == 2, 'Choice choice_id should be 2');
        assert(choice.text == 'Go right', 'Choice text should be Go right');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_player_state_struct() {
        let player_state = PlayerState {
            player: starknet::contract_address_const::<0x123>(),
            balance: 100,
            current_node: 5,
            story_completed: false,
        };
        assert(player_state.balance == 100, 'PlayerState balance != 100');
        assert(player_state.current_node == 5, 'PlayerState current_node != 5');
        assert(player_state.story_completed == false, 'PlayerState st_cmplted != false');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_player_decision_struct() {
        let player_decision = PlayerDecision {
            player: starknet::contract_address_const::<0x123>(),
            node_id: 1,
            choice: 0,
        };
        assert(player_decision.node_id == 1, 'PlayerDecision node_id != 1');
        assert(player_decision.choice == 0, 'PlayerDecision choice != 0');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_node_meta_struct() {
        let node_meta = NodeMeta {
            id: 10,
            text: 'Node text',
            gambling_node: true,
            is_ending: false,
        };
        assert(node_meta.id == 10, 'NodeMeta id should be 10');
        assert(node_meta.text == 'Node text', 'NodeMeta text != Node text');
        assert(node_meta.gambling_node == true, 'NodeMeta gambling_node != true');
        assert(node_meta.is_ending == false, 'NodeMeta is_ending != false');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_gambling_level_config_struct() {
        let gambling_config = GamblingLevelConfig {
            player: starknet::contract_address_const::<0x123>(),
            token: starknet::contract_address_const::<0x456>(),
            level: 1,
            multiplier: Multiplier::Mid,
            chances: Chances::High,
        };
        assert(gambling_config.level == 1, 'GamblingLevelConfig level != 1');
        assert(gambling_config.multiplier == Multiplier::Mid, 'GLConfig multiplier != Mid');
        assert(gambling_config.chances == Chances::High, 'GLConfig chances != High');
    }
}
