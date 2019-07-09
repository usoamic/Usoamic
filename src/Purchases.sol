pragma solidity ^0.4.19;

import "./Token.sol";
import "./Notes.sol";

contract Purchases is Notes, Token {
    using StringUtil for string;

    event MakePurchase(address indexed purchaser, string appId, string purchaseId, uint256 cost);

    struct Purchase {
        string purchaseId;
        string appId;
        uint256 cost;
        uint256 timestamp;
    }

    mapping(address => mapping(uint256 => Purchase)) private purchases;
    mapping(address => uint256) private numberOfPurchases;

    function makePurchase(string _appId, string _purchaseId, uint256 _cost) onlyUnfrozen public {
        require(!_appId.isEmpty());
        require(!_purchaseId.isEmpty());
        require(_cost > 0);

        transfer(getOwner(), _cost);

        uint256 numberOfPurchase = numberOfPurchases[msg.sender];

        purchases[msg.sender][numberOfPurchase] = Purchase({
            appId: _appId,
            purchaseId: _purchaseId,
            cost: _cost,
            timestamp: now
        });

        numberOfPurchases[msg.sender]++;

        MakePurchase(msg.sender, _appId, _purchaseId, _cost);
    }

    function getPurchaseByAddress(address _owner, uint256 _id) view public returns(bool exist, uint256 id, string purchaseId, string appId, uint256 cost, uint256 timestamp) {
        if(!isExistPurchase(_owner, _id)) {
            (exist, id) = (false, _id);
        }
        Purchase storage purchase = purchases[_owner][_id];
        return (true, _id, purchase.purchaseId, purchase.appId, purchase.cost, purchase.timestamp);
    }

    function getNumberOfPurchaseByAddress(address _owner) view public returns (uint256) {
        return numberOfPurchases[_owner];
    }

    function isExistPurchase(address _owner, uint256 _id) view private returns(bool) {
        return ((_id < numberOfPurchases[_owner]) && (_id >= 0));
    }
}
