pragma solidity ^0.4.18;

contract BlockExplorer {
    struct Transaction {
        uint256 timestamp;
        address from;
        address to;
        uint256 value;
        string hash;
    }

    mapping(address => Transaction[]) private addressTransactions;
    Transaction[] private transactions;

    function BlockExplorer() { }
}
