// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {ExpenseSplitter} from "src/ExpenseSplitter.sol";

contract DeployExpenseSplitter is Script {

    /* Functions */
    function run() public returns (ExpenseSplitter) {
        vm.startBroadcast();
        ExpenseSplitter expenseSplitter = new ExpenseSplitter();
        vm.stopBroadcast();
        return(expenseSplitter);
    }

}