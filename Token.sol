pragma solidity ^0.4.0;

interface Token {
    function burn(uint256 _value) onlyUnfrozen public returns (bool success);
    function approve(address _spender, uint256 _value) onlyUnfrozen public returns (bool success);
    function transfer(address _to, uint256 _value) onlyUnfrozen public;
}
