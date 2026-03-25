// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {ExpenseSplitter} from "src/ExpenseSplitter.sol";
import {DeployExpenseSplitter} from "script/DeployExpenseSplitter.s.sol";

contract TestExpenseSplitter is Test {
    /* Instantiate a new contract */
    ExpenseSplitter expenseSplitter;

    /* Errors */
    error ExpenseSplitter__YouAreNotTheOwner();

    /* State variables */
    address USER = makeAddr("user");
    address MEMBER = makeAddr("member");

    /* Events */
    event NewMember(address);

    /* Set up function */
    function setUp() external {
        DeployExpenseSplitter deployExpenseSplitter = new DeployExpenseSplitter();
        expenseSplitter = deployExpenseSplitter.run();
    }

    /* Testing functions */
    function testOwnerIsMsgSender() public view {
        assertEq(expenseSplitter.getOwner(), msg.sender);
    }

    function testOwnerCanAddMembers() public {
        // Arrange
        address owner = expenseSplitter.getOwner();
        vm.prank(owner);
        vm.expectEmit();
        emit NewMember(MEMBER);

        // Act / Assert
        expenseSplitter.addMember(MEMBER);
    }

    function testOnlyOwnerCanAddMembers() public {
        // Arrange
        vm.prank(USER);
        vm.expectRevert(ExpenseSplitter__YouAreNotTheOwner.selector);

        // Act / Assert
        expenseSplitter.addMember(MEMBER);
    }
}
