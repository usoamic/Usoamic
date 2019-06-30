pragma solidity ^0.4.18;

import "./TransactionExplorer.sol";

contract Swap is TransactionExplorer {
    uint256 private swapDeposit = 0;
    uint256 private swapRate = 1;
    bool private swappable = true;

    modifier onlySwappable {
        require(!swappable);
        _;
    }

    function depositEth() onlyOwner payable {
        swapDeposit += msg.value;
    }

    function burnSwap(uint256 _value) onlyUnfrozen onlySwappable public {
        uint256 numberOfWei = _value*swapRate;
        require(swapDeposit >= numberOfWei);
        msg.sender.transfer(_value);
        burn(_value);
    }

    function setSwapRate(uint256 _swapRate) onlyOwner public {
        swapRate = _swapRate;
    }

    function setSwappable(bool _swappable) onlyOwner {
        swappable = _swappable;
    }

    function getSwapDeposit() public view returns(uint256) {
        return swapDeposit;
    }

    function getSwapRate() public view returns(uint256) {
        return swapRate;
    }
}
