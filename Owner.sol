pragma solidity ^0.4.18;

contract Owner {
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
        require((owner != newOwner) && (newOwner != 0x0));
        owner = newOwner;
        SetOwner(newOwner);
    }
}