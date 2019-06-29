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

    function addTransaction(address _to, uint256 _value) internal {
        require(_value > 0);

        Transaction memory tx = Transaction({
            from: msg.sender,
            to: _to,
            value: _value,
            timestamp: now
        });

        addressTransactions[_to].push(tx);
        addressTransactions[msg.sender].push(tx);
        transactions.push(tx);
    }

    function getTransactionByAddress(address addr, uint256 txId) public view returns(bool exist, uint256 idOfTx, address from, address to, uint256 value, uint256 timestamp) {
        if(!isExistTransactionBySender(addr, txId)) {
            (exist, idOfTx) = (false, txId);
            return;
        }
        Transaction storage tx = addressTransactions[addr][txId];
        return (true, txId, tx.from, tx.to, tx.value, tx.timestamp);
    }

    function getTransaction(uint256 txId) public view returns(bool exist, uint256 idOfTx, address from, address to, uint256 value, uint256 timestamp) {
        if(!isExistTransaction(txId)) {
            (exist, idOfTx) = (false, txId);
            return;
        }
        Transaction storage tx = transactions[txId];
        return (true, txId, tx.from, tx.to, tx.value, tx.timestamp);
    }

    function isExistTransactionBySender(address addr, uint256 txId) view private returns(bool) {
        return ((txId < addressTransactions[addr].length) && (txId >= 0));
    }

    function isExistTransaction(uint256 txId) view private returns(bool) {
        return ((txId < transactions.length) && (txId >= 0));
    }
}
