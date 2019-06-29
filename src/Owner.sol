pragma solidity ^0.4.18;

import "../library/AddressUtil.sol";

contract Owner {
    using AddressUtil for address;
    event SetFrozen(bool contractFrozen);
    event SetOwner(address indexed newOwner);

    address public owner;
    bool public frozen = false;

    function Owner() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyUnfrozen {
        require(!frozen);
        _;
    }

    function setFronzen(bool contractFrozen) onlyOwner public {
        require(frozen != contractFrozen);
        frozen = contractFrozen;
        SetFrozen(contractFrozen);
    }

    function setOwner(address newOwner) onlyOwner public {
        require((owner != newOwner) && (!newOwner.isEmpty()));
        owner = newOwner;
        SetOwner(newOwner);
    }
}