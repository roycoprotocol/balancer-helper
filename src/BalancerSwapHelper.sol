// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IVault, IAsset} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IVault.sol";
import {WeirollWallet} from "lib/royco/src/WeirollWallet.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {FixedPointMathLib} from "lib/solmate/src/utils/FixedPointMathLib.sol";

contract BalancerSwapHelper {
    using FixedPointMathLib for uint256;

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;
    bytes32 constant POOL_ID = 0x8353157092ed8be69a9df8f95af097bbf33cb2af0000000000000000000005d9;
    IVault constant VAULT = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    uint256 constant MAX_SLIPPAGE = 0.998e18;

    /// @notice Swaps USDC to GHO using Balancer V2 for the calling Weiroll Wallet.
    /// @dev Approve amount of USDC to swap (fill amount) before executing this function.
    /// @dev Returns GHO tokens directly to the Weiroll Wallet.
    function helpSwap() public returns (uint256 amountOut) {
        // Get user's fill amount directly from the Weiroll Wallet
        uint256 amount = WeirollWallet(payable(msg.sender)).amount();

        // Transfer amount to swap from the Weiroll Wallet and approve Vault to swap it
        IERC20(USDC).transferFrom(msg.sender, address(this), amount);
        IERC20(USDC).approve(address(VAULT), amount);

        // Marshal swap parameters
        IVault.SingleSwap memory swapParams = IVault.SingleSwap({
            poolId: POOL_ID,
            kind: IVault.SwapKind.GIVEN_IN,
            assetIn: IAsset(USDC),
            assetOut: IAsset(GHO),
            amount: amount,
            userData: ""
        });

        IVault.FundManagement memory funds = IVault.FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: payable(msg.sender),
            toInternalBalance: false
        });

        // Amount of GHO tokens that must be received from swap based on max slippage
        uint256 limit = amount.mulWadDown(MAX_SLIPPAGE);
        // Enforce atomicity for the swap
        uint256 deadline = block.timestamp;

        // Execute the swap with the specified parameters
        amountOut = VAULT.swap(swapParams, funds, limit, deadline);
    }
}
