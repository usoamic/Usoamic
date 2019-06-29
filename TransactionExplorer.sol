pragma solidity ^0.4.18;

import "./library/AddressUtil.sol";

contract TransactionExplorer {
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

    function addTransaction(address _to, uint256 _value) internal {
        require(_value > 0);

        Transaction tx = Transaction({
            from: msg.sender,
            to: _to,
            value: _value,
            timestamp: now
        });

        addressTransactions[_to].push(tx);
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
