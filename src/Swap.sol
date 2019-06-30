pragma solidity ^0.4.18;

import "./TransactionExplorer.sol";

contract Swap is TransactionExplorer {
    uint256 private swapRate = 1;
    bool private swappable = true;

    modifier onlySwappable {
        require(!swappable);
        _;
    }

    function depositEth() onlyOwner payable { }

    function withdrawEth(uint256 _value) onlyOwner public {
        require(isEnoughEth(_value));
        msg.sender.transfer(_value);
    }

    function burnSwap(uint256 _value) onlyUnfrozen onlySwappable public {
        uint256 numberOfEth = _value*swapRate;
        require(isEnoughEth(_value));
        msg.sender.transfer(_value);
        burn(_value);
    }

    function setSwapRate(uint256 _swapRate) onlyOwner public {
        swapRate = _swapRate;
    }

    function setSwappable(bool _swappable) onlyOwner {
        swappable = _swappable;
    }

    function isEnoughEth(uint256 _value) view private returns(bool) {
        return (this.balance >= numberOfEth);
    }

    function getSwapBalance() public view returns(uint256) {
        return this.balance;
    }

    function getSwapRate() public view returns(uint256) {
        return swapRate;
    }
}
