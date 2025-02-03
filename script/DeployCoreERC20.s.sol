// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {CoreERC20} from "../src/CoreERC20.sol";

contract DeployCoreERC20 is Script {

    // Test variables
    string public constant NAME = "Test Token";
    string public constant SYMBOL = "TEST";
    uint8 public constant DECIMALS = 18;
    uint256 public constant TOTAL_SUPPLY = 1000000;

    function run() external returns (CoreERC20) {
        vm.startBroadcast();
        CoreERC20 coreERC20 = new CoreERC20(NAME, SYMBOL, DECIMALS, TOTAL_SUPPLY);
        vm.stopBroadcast();
        return coreERC20;
    }

}