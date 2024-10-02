// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Bank {
    address payable public owner;
    address[] public accounts;

    struct User {
        address userAccount; // User's wallet address
        uint256 balance; // User's current balance
        uint256 timeCreated; // Time of account creation
    }

    // Mapping to track registered users and their details
    mapping(address => User) public users;

    // Event to log account creation
    event AccountCreated(address indexed account, uint256 timestamp);
    // Event to log fund deposit
    event FundsDeposited(address indexed account, uint256 amount);
    // Event to log fund transfer
    event FundsTransferred(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    // Event to log withdrawal
    event Withdrawal(address indexed account, uint256 amount);

    // Constructor to set the contract deployer as the owner
    constructor() {
        owner = payable(msg.sender);
    }

    // Modifier to check if the account exists
    modifier accountExists(address _account) {
        require(
            users[_account].userAccount != address(0),
            "Account does not exist."
        );
        _;
    }

    // Function to create an account
    function createAccount() external {
        require(
            users[msg.sender].userAccount == address(0),
            "This account is already registered."
        );

        // Create a new user
        users[msg.sender] = User({
            userAccount: msg.sender,
            balance: 0,
            timeCreated: block.timestamp
        });

        // Add to the list of accounts
        accounts.push(msg.sender);
        emit AccountCreated(msg.sender, block.timestamp);
    }

    // Function to deposit funds into the contract (e.g., to top up balance)
    function deposit() external payable accountExists(msg.sender) {
        require(msg.value > 0, "Deposit amount must be greater than zero.");

        // Update user balance
        users[msg.sender].balance += msg.value;
        emit FundsDeposited(msg.sender, msg.value);
    }

    // Function to withdraw funds from the contract
    function withdraw(uint256 _amount) external accountExists(msg.sender) {
        require(users[msg.sender].balance >= _amount, "Insufficient balance.");

        users[msg.sender].balance -= _amount; // Reduce the user balance
        payable(msg.sender).transfer(_amount); // Transfer the amount to the user

        emit Withdrawal(msg.sender, _amount);
    }

    // Function to transfer funds to another account within the bank
    function transferFunds(
        uint256 _amount,
        address _recipient
    ) external accountExists(msg.sender) accountExists(_recipient) {
        require(_amount > 0, "Transfer amount must be greater than zero.");
        require(users[msg.sender].balance >= _amount, "Insufficient balance.");

        // Adjust the balances
        users[msg.sender].balance -= _amount;
        users[_recipient].balance += _amount;

        emit FundsTransferred(msg.sender, _recipient, _amount);
    }

    // Function to check the balance of the sender's account
    function getBalance() external view accountExists(msg.sender) returns (uint256) {
        return users[msg.sender].balance;
    }

    // Function to get the contract's total balance (all users' balances)
    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    // Function to get the list of all registered accounts
    function getAccounts() external view returns (address[] memory) {
        return accounts;
    }
}
