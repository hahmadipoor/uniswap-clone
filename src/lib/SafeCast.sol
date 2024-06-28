// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.19;

library SafeCast {
    
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y <= uint256(type(int256).max));
        z = int256(y);
    }

    function toInt128(uint256 y) internal pure returns (int128 z) {
        require(y <= uint128(type(int128).max));
        z = int128(int256(y));
    }
}
