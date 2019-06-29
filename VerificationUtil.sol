pragma solidity ^0.4.18;

contract VerificationUtil {
    function isEmptyString(string str) internal pure returns (bool) {
        return (bytes(str).length == 0);
    }

    function isEmptyAddress(address addr) internal pure returns(bool) {
        return (addr == 0x0);
    }
}