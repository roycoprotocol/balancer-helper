// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "lib/forge-std/src/Test.sol";
import {BalancerSwapHelper} from "../src/BalancerSwapHelper.sol";
import {IERC20} from "lib/forge-std/src/interfaces/IERC20.sol";

contract BalancerSwapHelperTest is Test {
    BalancerSwapHelper helper;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;
    address constant WHALE = 0x7713974908Be4BEd47172370115e8b1219F4A5f0; // Random USDC whale

    function setUp() public {
        helper = new BalancerSwapHelper();
        // vm.createSelectFork(MAINNET_RPC_URL);
    }

    function testHelpSwap() public {
        uint256 amount = 1000 * 1e6; // 1000 USDC
        
        // Impersonate whale and approve helper
        vm.startPrank(WHALE);
        IERC20(USDC).approve(address(helper), amount);
        
        uint256 ghoBalanceBefore = IERC20(GHO).balanceOf(WHALE);
        uint256 usdcBalanceBefore = IERC20(USDC).balanceOf(WHALE);

        // Execute swap
        uint256 amountOut = helper.helpSwap(payable(WHALE), amount);
        
        uint256 ghoBalanceAfter = IERC20(GHO).balanceOf(WHALE);
        uint256 usdcBalanceAfter = IERC20(USDC).balanceOf(WHALE);

        // Verify balances changed correctly
        assertEq(usdcBalanceBefore - usdcBalanceAfter, amount, "Incorrect USDC deducted");
        assertEq(ghoBalanceAfter - ghoBalanceBefore, amountOut, "Incorrect GHO received");
        assertTrue(amountOut > 0, "No GHO received");

        vm.stopPrank();
    }

    function testFailInsufficientAllowance() public {
        uint256 amount = 1000 * 1e6; // 1000 USDC
        
        // Try to swap without approval
        vm.prank(WHALE);
        helper.helpSwap(payable(WHALE), amount);
    }

    function testFailInsufficientBalance() public {
        uint256 amount = 1_000_000_000 * 1e6; // 1B USDC
        
        vm.startPrank(WHALE);
        IERC20(USDC).approve(address(helper), amount);
        
        // Try to swap more than whale's balance
        helper.helpSwap(payable(WHALE), amount);
        vm.stopPrank();
    }
}
