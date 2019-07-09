pragma solidity ^0.4.19;

import "../library/AddressUtil.sol";

contract Owner {
    using AddressUtil for address;

    event SetFrozen(bool contractFrozen);
    event SetOwner(address indexed newOwner);

    address private owner;
    bool private frozen = false;

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

    function setFrozen(bool _contractFrozen) onlyOwner public {
        require(frozen != _contractFrozen);
        frozen = _contractFrozen;
        SetFrozen(_contractFrozen);
    }

    function setOwner(address _newOwner) onlyOwner public {
        require((owner != _newOwner) && (!_newOwner.isEmpty()));
        owner = _newOwner;
        SetOwner(_newOwner);
    }

    function getFrozen() public view returns(bool) {
        return frozen;
    }

    function getOwner() public view returns(address) {
        return owner;
    }
}