pragma solidity ^0.4.18;

import "./Purchases.sol";

contract TransactionExplorer is Purchases {
    using AddressUtil for address;

    struct Transaction {
        uint256 txId;
        address from;
        address to;
        uint256 value;
        uint256 timestamp;
    }

    mapping(address => uint256) private numberOfAddressTransactions;
    mapping(address => mapping(uint256 => uint256)) private addressTransactions;
    mapping(uint256 => Transaction) private transactions;

    uint256 private numberOfTransactions = 0;

    function addTransaction(address _to, uint256 _value) onlyUnfrozen internal {
        require(_value > 0);

        putTransaction(msg.sender);
        putTransaction(_to);

        transactions[numberOfTransactions] = Transaction({
            txId: numberOfTransactions,
            from: msg.sender,
            to: _to,
            value: _value,
            timestamp: now
        });

        numberOfTransactions++;
    }

    function addTransactionToAddress(address _owner, uint256 txId) private {
        addressTransactions[msg.sender][numberOfAddressTransactions[msg.sender]] = numberOfTransactions;
        numberOfAddressTransactions[_owner]++;
    }

    function getTransactionByAddress(address _owner, uint256 _txNumber) public view returns(bool exist, uint256 txId, uint256 txNumber, address from, address to, uint256 value, uint256 timestamp) {
        if(!isExistTransactionBySender(_owner, _txNumber)) {
            (exist, txId) = (false, _txNumber);
            return;
        }
        Transaction storage tx = addressTransactions[_owner][_txNumber];
        return (true, txId_txNumber, tx.from, tx.to, tx.value, tx.timestamp);
    }

    function getTransaction(uint256 _txId) public view returns(bool exist, uint256 txId, address from, address to, uint256 value, uint256 timestamp) {
        if(!isExistTransaction(_txId)) {
            (exist, txId) = (false, _txId);
            return;
        }
        TransactionRef storage tx = transactions[_txId];
        return getTransactionByAddress(tx.from, _txId);
    }

    function getNumberOfTransactions() public {
        return numberOfTransactions;
    }

    function getNumberOfTransactionsByAddress(address _owner) public {
        return numberOfAddressTransactions[_owner];
    }

    function isExistTransactionBySender(address _owner, uint256 _txId) view private returns(bool) {
        return ((_txId < numberOfAddressTransactions[_owner]) && (_txId >= 0));
    }

    function isExistTransaction(uint256 _txId) view private returns(bool) {
        return ((_txId < numberOfTransactions) && (_txId >= 0));
    }
}
