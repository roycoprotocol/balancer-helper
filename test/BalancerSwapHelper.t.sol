// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Test } from "lib/forge-std/src/Test.sol";
import { BalancerSwapHelper } from "../src/BalancerSwapHelper.sol";
import { WeirollWallet } from "lib/royco/src/WeirollWallet.sol";
import { ClonesWithImmutableArgs } from "lib/royco/lib/clones-with-immutable-args/src/ClonesWithImmutableArgs.sol";
import { IERC20 } from "lib/forge-std/src/interfaces/IERC20.sol";

contract BalancerSwapHelperTest is Test {
    using ClonesWithImmutableArgs for address;

    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;

    BalancerSwapHelper helper;
    address weirollWalletImplementation;
    address weirollWallet;

    string MAINNET_RPC_URL = vm.envString("MAINNET_RPC_URL");

    function setUp() public {
        helper = new BalancerSwapHelper();
        weirollWalletImplementation = address(new WeirollWallet());
        vm.createSelectFork(MAINNET_RPC_URL);
    }

    function testhelpSwap(uint256 amount) public {
        amount = bound(amount, 1e6, 1_000_000e6);

        weirollWallet = weirollWalletImplementation.clone(abi.encodePacked(address(0xbeef), address(this), amount, uint256(0), false, bytes32(0)));

        // Fund the Weiroll Wallet with the fuzzed amount
        deal(USDC, weirollWallet, amount);

        // Impersonate the Weiroll Wallet and approve helper
        vm.startPrank(weirollWallet);
        IERC20(USDC).approve(address(helper), amount);

        uint256 ghoBalanceBefore = IERC20(GHO).balanceOf(weirollWallet);
        uint256 usdcBalanceBefore = IERC20(USDC).balanceOf(weirollWallet);

        // Execute swap
        uint256 amountOut = helper.helpSwap();

        uint256 ghoBalanceAfter = IERC20(GHO).balanceOf(weirollWallet);
        uint256 usdcBalanceAfter = IERC20(USDC).balanceOf(weirollWallet);

        // Verify balances changed correctly
        assertEq(usdcBalanceBefore - usdcBalanceAfter, amount, "Incorrect USDC deducted");
        assertEq(ghoBalanceAfter - ghoBalanceBefore, amountOut, "Incorrect GHO received");
        assertTrue(amountOut > 0, "No GHO received");

        vm.stopPrank();
    }

    function testFailInsufficientAllowance() public {
        // Try to swap without approval
        vm.prank(weirollWallet);
        helper.helpSwap();
    }

    function testFailInsufficientBalance() public {
        uint256 amount = 1_000_000_000 * 1e6; // 1B USDC

        vm.startPrank(weirollWallet);
        IERC20(USDC).approve(address(helper), amount);

        // Try to swap more than weirollWallet's balance
        helper.helpSwap();
        vm.stopPrank();
    }
}
