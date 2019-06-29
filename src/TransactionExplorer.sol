pragma solidity ^0.4.18;

import "./Purchases.sol";

contract TransactionExplorer is Purchases {
    using AddressUtil for address;

    struct Transaction {
        address from;
        address to;
        uint256 value;
        uint256 timestamp;
    }

    mapping(address => Transaction[]) private addressTransactions;
    Transaction[] private transactions;

    function addTransaction(address _to, uint256 _value) onlyUnfrozen internal {
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

    function getTransactionByAddress(address _owner, uint256 _txId) public view returns(bool exist, uint256 txId, address from, address to, uint256 value, uint256 timestamp) {
        if(!isExistTransactionBySender(_owner, _txId)) {
            (exist, txId) = (false, _txId);
            return;
        }
        Transaction storage tx = addressTransactions[_owner][_txId];
        return (true, _txId, tx.from, tx.to, tx.value, tx.timestamp);
    }

    function getTransaction(uint256 _txId) public view returns(bool exist, uint256 txId, address from, address to, uint256 value, uint256 timestamp) {
        if(!isExistTransaction(_txId)) {
            (exist, txId) = (false, _txId);
            return;
        }
        Transaction storage tx = transactions[_txId];
        return (true, _txId, tx.from, tx.to, tx.value, tx.timestamp);
    }

    function isExistTransactionBySender(address _owner, uint256 _txId) view private returns(bool) {
        return ((_txId < addressTransactions[_owner].length) && (_txId >= 0));
    }

    function isExistTransaction(uint256 _txId) view private returns(bool) {
        return ((_txId < transactions.length) && (_txId >= 0));
    }
}
