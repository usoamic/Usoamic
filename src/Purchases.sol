pragma solidity ^0.4.0;

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

    mapping(address => Purchase[]) private purchases;

    function makePurchase(string _appId, string _purchaseId, uint256 _cost) onlyUnfrozen public {
        require(!_appId.isEmpty());
        require(!_purchaseId.isEmpty());
        require(_cost > 0);

        transfer(owner, _cost);
        Purchase memory purchase = Purchase({
            appId: _appId,
            purchaseId: _purchaseId,
            cost: _cost,
            timestamp: now
        });
        purchases[msg.sender].push(purchase);
        MakePurchase(msg.sender, _appId, _purchaseId, _cost);
    }

    function getPurchaseByAddress(address _owner, uint256 _purchaseId) view public returns(bool exist, uint256 purchaseId, string appId, uint256 cost, uint256 timestamp) {
        if(!isExistPurchase(_owner, _purchaseId)) {
            (exist, purchaseId) = (false, _purchaseId);
        }
        Purchase storage purchase = purchases[_owner][_purchaseId];
        return (true, purchase.purchaseId, purchase.appId, purchase.cost, purchase.timestamp);
    }

    function isExistPurchase(address _owner, uint256 _purchaseId) view private returns(bool) {
        return ((_purchaseId < purchases[_owner].length) && (_purchaseId >= 0));
    }
}
