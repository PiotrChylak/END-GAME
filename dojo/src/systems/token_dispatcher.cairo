use starknet::ContractAddress;

pub trait ITokenDispatcher<T> {
    fn total_supply(self: T, contract_address: ContractAddress) -> u256;
    fn balance_of(self: T, token_contract_address: ContractAddress, account: ContractAddress) -> u256;
    fn transfer(self: T, token_contract_address: ContractAddress, recipient: ContractAddress, amount: u256);
    fn transfer_from(self: T, token_contract_address: ContractAddress, sender: ContractAddress, recipient: ContractAddress, amount: u256);
}

mod Token {
    use openzeppelin::token::erc20::ERC20ABIDispatcher;
    use openzeppelin::token::erc20::ERC20ABIDispatcherTrait;
    use starknet::ContractAddress;

    #[derive(Copy, Drop, starknet::Store, Serde)]
    struct IERC20Dispatcher {
        pub contract_address: ContractAddress,
    }

    impl TokenDispatcherImpl of super::ITokenDispatcher<IERC20Dispatcher> {
        fn total_supply(self: IERC20Dispatcher, contract_address: ContractAddress) -> u256 {
            ERC20ABIDispatcher{contract_address}.total_supply()
        }
        fn balance_of(self: IERC20Dispatcher, token_contract_address: ContractAddress, account: ContractAddress) -> u256 {
            ERC20ABIDispatcher{contract_address: token_contract_address}.balance_of(account)
        }
        fn transfer(self: IERC20Dispatcher, token_contract_address: ContractAddress, recipient: ContractAddress, amount: u256){
            ERC20ABIDispatcher{contract_address: token_contract_address}.transfer(recipient, amount);
        }
        fn transfer_from(self: IERC20Dispatcher, token_contract_address: ContractAddress, sender: ContractAddress, recipient: ContractAddress, amount: u256){
            ERC20ABIDispatcher{contract_address: token_contract_address}.transfer_from(sender, recipient, amount);
        }
    }

}