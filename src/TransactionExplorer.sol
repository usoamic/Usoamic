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

    struct TransactionRef {
        uint256 txId;
        address sender;
    }

    mapping(address => uint256) private numberOfAddressTransactions;
    mapping(address => mapping(uint256 => Transaction)) private addressTransactions;
    mapping(uint256 => TransactionRef) private transactions;

    uint256 private numberOfTransactions = 0;

    function addTransaction(address _to, uint256 _value) onlyUnfrozen internal {
        require(_value > 0);

        addressTransactions[_to][numberOfAddressTransactions[msg.sender]] = Transaction({
            from: msg.sender,
            to: _to,
            value: _value,
            timestamp: now
        });

        transactions[numberOfTransactions] = TransactionRef({
            txId: msg.sender,
            sender: msg.sender
        });

        numberOfAddressTransactions[msg.sender]++;
        numberOfTransactions++;
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

    function numberOfTransactions() public {
        return numberOfTransactions;
    }

    function numberOfTransactionsByAddress(address _owner) public {
        return numberOfAddressTransactions[_owner];
    }

    function isExistTransactionBySender(address _owner, uint256 _txId) view private returns(bool) {
        return ((_txId < numberOfAddressTransactions[_owner]) && (_txId >= 0));
    }

    function isExistTransaction(uint256 _txId) view private returns(bool) {
        return ((_txId < numberOfTransactions) && (_txId >= 0));
    }
}
