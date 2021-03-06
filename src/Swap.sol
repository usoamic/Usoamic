pragma solidity ^0.4.18;

import "./TransactionExplorer.sol";

contract Swap is TransactionExplorer {
    uint256 private swapRate = 4000000;
    bool private swappable = false;

    modifier onlySwappable {
        require(swappable);
        _;
    }

    function () onlyOwner payable public { }

    function withdrawEth(uint256 _value) onlyOwner public {
        require(isEnoughEth(_value));
        msg.sender.transfer(_value);
    }

    function burnSwap(uint256 _value) onlyUnfrozen onlySwappable public {
        uint256 numberOfEth = _value*swapRate;
        require(isEnoughEth(numberOfEth));
        msg.sender.transfer(numberOfEth);
        burn(_value);
    }

    function setSwapRate(uint256 _swapRate) onlyOwner public {
        swapRate = _swapRate;
    }

    function setSwappable(bool _swappable) onlyOwner {
        swappable = _swappable;
    }

    function isEnoughEth(uint256 _value) view private returns(bool) {
        return (this.balance >= _value);
    }

    function getSwappable() public view returns(bool) {
        return swappable;
    }

    function getSwapBalance() public view returns(uint256) {
        return this.balance;
    }

    function getSwapRate() public view returns(uint256) {
        return swapRate;
    }
}
