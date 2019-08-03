pragma solidity ^0.4.19;

interface Token {
    function burn(uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function transfer(address _to, uint256 _value) public;
}
