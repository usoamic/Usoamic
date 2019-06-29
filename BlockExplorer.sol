pragma solidity ^0.4.18;

import "./library\AddressUtil.sol";

contract BlockExplorer {
    using AddressUtil for address;

    struct Transaction {
        address from;
        address to;
        uint256 value;
        uint256 timestamp;
    }

    mapping(address => Transaction[]) private addressTransactions;
    Transaction[] private transactions;

    function BlockExplorer() { }

    function addTransaction(address to, uint256 value) private {
        require(!to.isEmpty && value > 0);

        Transaction tx = Transaction({
            from: msg.sender,
            to: to,
            value: value,
            timestamp: now
        });

        addressTransactions[to].push(tx);
        addressTransactions[msg.sender].push(tx);
        transactions.push(tx);
    }

    function getTransaction(address addr, uint256 id) public view returns(address from, address to, uint256 value, uint256 timestamp) {
        Transaction storage tx = addressTransactions[addr][id];
        return (tx.from, tx.to, tx.value, tx.timestamp);
    }

    function getTransaction(uint256 id) public view returns(address from, address to, uint256 value, uint256 timestamp) {
        Transaction storage tx = transactions[id];
        return (tx.from, tx.to, tx.value, tx.timestamp);
    }
}
