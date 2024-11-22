// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IVault} from "../lib/balancer-v2-monorepo/pkg/interfaces/contracts/vault/IVault.sol";

contract BalancerSwapHelper {

    address constant GHO = 0x40D16FC0246aD3160Ccc09B8D0D3A2cD28aE6C2f;
    address constant POOL = 0x854B004700885A61107B458f11eCC169A019b764;
    address constant VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    
    /// @dev approve first, returns tokens directly to wallet
    function helpSwap(address wallet, address owner, address amount) public returns (uint256 amountOut) {
        // IVault(VAULT).approve(POOL, amount);
    }
}
