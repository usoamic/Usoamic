pragma solidity ^0.4.0;

import "./Ideas.sol";
import "./Token.sol";

contract Purchases is Ideas, Token {
    event MakePurchase(address indexed purchaser, string appId, string purchaseId, uint256 cost);

    struct Purchase {
        string appId;
        string purchaseId;
        uint256 cost;
        uint256 timestamp;
    }

    mapping(address => Purchase[]) private purchases;

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
}
