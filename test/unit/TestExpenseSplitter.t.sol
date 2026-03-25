// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {ExpenseSplitter} from "src/ExpenseSplitter.sol";
import {DeployExpenseSplitter} from "script/DeployExpenseSplitter.s.sol";

contract TestExpenseSplitter is Test {
    /* Instantiate a new contract */
    ExpenseSplitter expenseSplitter;

    /* Errors */

    /* State variables */
    address USER = makeAddr("user");

    /* Set up function */
    function setUp() external {
        DeployExpenseSplitter deployExpenseSplitter = new DeployExpenseSplitter();
        expenseSplitter = deployExpenseSplitter.run();
    }

    /* Testing functions */
    function testOwnerIsMsgSender() public view {
        assertEq(expenseSplitter.getOwner(), msg.sender);
    }
}
