use starknet::ContractAddress;

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