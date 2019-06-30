pragma solidity ^0.4.18;

import "./TransactionExplorer.sol";

contract Swap is TransactionExplorer {
    uint256 private swapDeposit = 0;

    function depositEth() onlyOwner payable {
        swapDeposit += msg.value;
    }

    function burnSwap(uint256 _value) onlyUnfrozen public {
        uint256 numberOfWei = _value*1;
        msg.sender.transfer(_value);
        burn(_value);
    }
}
