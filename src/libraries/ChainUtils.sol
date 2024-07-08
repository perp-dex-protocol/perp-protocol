// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import "../interfaces/IArbSys.sol";
import "../interfaces/mock/IBlockManager_Mock.sol";

/**
 * @dev Chain helpers internal library
 */
library ChainUtils {
    // Supported chains
    uint256 internal constant ARBITRUM_MAINNET = 42161;
    uint256 internal constant ARBITRUM_SEPOLIA = 421614;
    uint256 internal constant POLYGON_MAINNET = 137;
    uint256 internal constant TESTNET = 31337;

    // Wrapped native tokens
    address private constant ARBITRUM_MAINNET_WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
    address private constant ARBITRUM_SEPOLIA_WETH = 0x980B62Da83eFf3D4576C647993b0c1D7faf17c73;
    address private constant POLYGON_MAINNET_WMATIC = 0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270;

    IArbSys private constant ARB_SYS = IArbSys(address(100));

    error Overflow();

    /**
     * @dev Returns the current block number (l2 block for arbitrum)
     */
    function getBlockNumber() internal view returns (uint256) {
        if (block.chainid == ARBITRUM_MAINNET || block.chainid == ARBITRUM_SEPOLIA) {
            return ARB_SYS.arbBlockNumber();
        }

        if (block.chainid == TESTNET) {
            return IBlockManager_Mock(address(420)).getBlockNumber();
        }

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
    function getWrappedNativeToken() internal view returns (address) {
        if (block.chainid == ARBITRUM_MAINNET) {
            return ARBITRUM_MAINNET_WETH;
        }

        if (block.chainid == POLYGON_MAINNET) {
            return POLYGON_MAINNET_WMATIC;
        }

        if (block.chainid == ARBITRUM_SEPOLIA) {
            return ARBITRUM_SEPOLIA_WETH;
        }

        if (block.chainid == TESTNET) {
            return address(421);
        }

        return address(0);
    }

    /**
     * @dev Returns whether a token is the wrapped native token for the current chain
     * @param _token token address to check
     */
    function isWrappedNativeToken(address _token) internal view returns (bool) {
        return _token != address(0) && _token == getWrappedNativeToken();
    }
}
