// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IVault} from "lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IVault.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";
import {FixedPointMathLib} from "lib/

contract BalancerSwapHelper {

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;
    address constant POOL = 0x854B004700885A61107B458f11eCC169A019b764;
    IVault constant VAULT = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);

    uint256 constant MAX_SLIPPAGE = .995e18
    
    /// @dev approve first, returns tokens directly to wallet
    function helpSwap(address wallet, address owner, uint256 amount) public returns (uint256 amountOut) {
        IERC20(USDC).transferFrom(wallet, address(this), amount);

        IERC20(USDC).approve(address(POOL), amount);
        IVault.SingleSwap memory swap = IVault.SingleSwap({
            poolId: bytes32(abi.encode(POOL)),
            kind: IVault.SwapKind.GIVEN_IN,
            assetIn: IVault.IAsset(USDC),
            assetOut: IVault.IAsset(GHO),
            amount: amount,
            userData: ""
        });

        IVault.FundManagement memory funds = IVault.FundManagement({
            sender: address(this),
            fromInternalBalance: false,
            recipient: owner,
            toInternalBalance: false
        });

        uint256 limit = 

        IVault.swap(swap, funds, )
        
        // VAULT.swap(swap, FundManagement({sender: owner, recipient: wallet, fromInternalBalance: false, toInternalBalance: false}), amount, block.timestamp);
        // IVault(VAULT).approve(POOL, amount);
    }
}
