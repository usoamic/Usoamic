pragma solidity ^0.4.0;

import "./Ideas.sol";
import "./Token.sol";

contract Purchases is Ideas, Token {
    event MakePurchase(address indexed purchaser, string appId, string purchaseId, uint256 cost);

    struct Purchase {
        string purchaseId;
        string appId;
        uint256 cost;
        uint256 timestamp;
    }

    mapping(address => Purchase[]) private purchases;

    function getPurchaseByAddress(address owner, uint256 purchaseId) view public returns(bool exist, uint256 idOfPurchase, string appId, uint256 cost, uint256 timestamp) {
        if(!isExistPurchase(owner, purchaseId)) {
            (exist, idOfPurchase) = (false, purchaseId);
        }
        Purchase storage purchase = purchases[owner][purchaseId];
        return (true, purchase.purchaseId, purchase.appId, purchase.cost, purchase.timestamp);
    }

    function makePurchase(string _appId, string _purchaseId, uint256 _cost) public {
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

    function isExistPurchase(address owner, uint256 purchaseId) view private returns(bool) {
        return ((purchaseId < purchases[owner].length) && (purchaseId >= 0));
    }
}
