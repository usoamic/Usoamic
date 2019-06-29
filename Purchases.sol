pragma solidity ^0.4.0;

contract Purchases {
    struct Purchase {
        string appId;
        string purchaseId;
        uint256 cost;
        uint256 timestamp;
    }

}
