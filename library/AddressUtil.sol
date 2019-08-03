pragma solidity ^0.4.0;

library AddressUtil {
    function isEmpty(address self) internal pure returns(bool) {
        return (self == 0x0);
    }
}
