pragma solidity ^0.4.18;

import "./TransactionExplorer.sol";

contract Swap is TransactionExplorer {
    uint256 private swapDeposit = 0;
    uint256 private swapRate = 1;

    function depositEth() onlyOwner payable {
        swapDeposit += msg.value;
    }

    function setSwapRate(uint256 _value) onlyOwner public {
        swapRate = _value;
    }

    function burnSwap(uint256 _value) onlyUnfrozen public {
        uint256 numberOfWei = _value*swapRate;
        msg.sender.transfer(_value);
        burn(_value);
    }
}
