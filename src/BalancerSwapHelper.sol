// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IVault, IAsset} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IVault.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {FixedPointMathLib} from "lib/solmate/src/utils/FixedPointMathLib.sol";

contract BalancerSwapHelper {
    using FixedPointMathLib for uint256;

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;
    // address constant POOL = 0x8353157092ED8Be69a9DF8F95af097bbF33Cb2aF;
    bytes32 constant POOL_ID = 0x8353157092ed8be69a9df8f95af097bbf33cb2af0000000000000000000005d9;
    IVault constant VAULT = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    uint256 constant MAX_SLIPPAGE = .998e18;
    
    /// @dev approve first, returns tokens directly to wallet
    function helpSwap(address payable wallet, uint256 amount) public returns (uint256 amountOut) {
        IERC20(USDC).transferFrom(wallet, address(this), amount);

        IERC20(USDC).approve(address(VAULT), amount);
        IVault.SingleSwap memory swap = IVault.SingleSwap({
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
            recipient: wallet,
            toInternalBalance: false
        });

        uint256 limit = amount.mulWadDown(MAX_SLIPPAGE);
        uint256 deadline = type(uint256).max;

        return VAULT.swap(swap, funds, limit, deadline);
    }
}
