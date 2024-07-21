// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../interfaces/IArbSys.sol";
import "../interfaces/mock/IBlockManager_Mock.sol";

/**
 * @dev Chain helpers internal library
 */
library ChainUtils {
    // Supported chains
    uint256 internal constant SEI_MAINNET = 1329;

    // Wrapped native tokens
    address private constant SEI_MAINNET_WSEI = 0xE30feDd158A2e3b13e9badaeABaFc5516e95e8C7;

    error Overflow();

    /**
     * @dev Returns the current block number (l2 block for arbitrum)
     */
    function getBlockNumber() internal view returns (uint256) {
        return block.number;
    }

    /**
     * @dev Returns blockNumber converted to uint48
     * @param blockNumber block number to convert
     */
    function getUint48BlockNumber(uint256 blockNumber) internal pure returns (uint48) {
        if (blockNumber > type(uint48).max) revert Overflow();
        return uint48(blockNumber);
    }

    /**
     * @dev Returns the wrapped native token address for the current chain
     */
    function getWrappedNativeToken() internal pure returns (address) {
        return SEI_MAINNET_WSEI;
    }

    /**
     * @dev Returns whether a token is the wrapped native token for the current chain
     * @param _token token address to check
     */
    function isWrappedNativeToken(address _token) internal pure returns (bool) {
        return _token != address(0) && _token == getWrappedNativeToken();
    }
}
