pragma solidity ^0.4.0;

library StringUtil {
    function isEmpty(string self) internal pure returns (bool) {
        return (bytes(self).length == 0);
    }
}
