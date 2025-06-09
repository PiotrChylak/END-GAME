use starknet::ContractAddress;

pub trait ITokenDispatcherTrait<T> {
    fn total_supply(self: T, token_contract_address: ContractAddress) -> u256;
    fn balance_of(self: T, token_contract_address: ContractAddress, account: ContractAddress) -> u256;
    fn transfer(self: T, token_contract_address: ContractAddress, recipient: ContractAddress, amount: u256);
}

pub mod Token {
    use openzeppelin::token::erc20::ERC20ABIDispatcher;
    use openzeppelin::token::erc20::ERC20ABIDispatcherTrait;
    use starknet::ContractAddress;

    #[derive(Copy, Drop, starknet::Store, Serde)]
    pub struct ITokenDispatcher {
        pub contract_address: ContractAddress,
    }

    impl TokenDispatcherImpl of super::ITokenDispatcherTrait<ITokenDispatcher> {
        fn total_supply(self: ITokenDispatcher, token_contract_address: ContractAddress) -> u256 {
            ERC20ABIDispatcher{contract_address: token_contract_address}.total_supply()
        }
        fn balance_of(self: ITokenDispatcher, token_contract_address: ContractAddress, account: ContractAddress) -> u256 {
            ERC20ABIDispatcher{contract_address: token_contract_address}.balance_of(account)
        }
        fn transfer(self: ITokenDispatcher, token_contract_address: ContractAddress, recipient: ContractAddress, amount: u256){
            ERC20ABIDispatcher{contract_address: token_contract_address}.transfer(recipient, amount);
        }
    }

}