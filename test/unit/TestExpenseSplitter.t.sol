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
    error ExpenseSplitter__YouAreNotAMember();

    /* State variables */
    address USER = makeAddr("user");
    address MEMBER = makeAddr("member");
    uint256 constant FUNDS = 10 ether;
    uint256 constant SEND_VALUE = 0.1 ether;

    /* Events */
    event NewMember(address);

    /* Set up function */
    function setUp() external {
        DeployExpenseSplitter deployExpenseSplitter = new DeployExpenseSplitter();
        expenseSplitter = deployExpenseSplitter.run();
        vm.deal(USER, FUNDS);
        vm.deal(MEMBER, FUNDS);
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

    function testNonMemberCannotContribute() public {
        // Arrange
        vm.prank(USER);
        vm.expectRevert(ExpenseSplitter__YouAreNotAMember.selector);

        // Act / Asser
        expenseSplitter.contribute();
    }

    function testContributingIncreasesContractBalance() public {
        // Arrange
        address owner = expenseSplitter.getOwner();
        vm.prank(owner);
        expenseSplitter.addMember(USER);

        // Act
        vm.prank(USER);
        expenseSplitter.contribute{value: SEND_VALUE}();
        uint256 contractBalance = address(expenseSplitter).balance;

        // Assert
        assertEq(contractBalance, SEND_VALUE);
    }

    function testSplitFundsGetsRightAmount() public {
        // Arrange
        address owner = expenseSplitter.getOwner();
        vm.startPrank(owner);
        expenseSplitter.addMember(USER);
        expenseSplitter.addMember(MEMBER);
        vm.stopPrank();

        // Act
        vm.prank(USER);
        expenseSplitter.contribute{value: SEND_VALUE}();

        vm.prank(MEMBER);
        expenseSplitter.contribute{value: SEND_VALUE}();

        vm.prank(owner);
        expenseSplitter.splitFunds();

        uint256 expectedShare = (SEND_VALUE * 2) / 2;

        // Assert
        assertEq(expenseSplitter.getClaimableShare(USER), expectedShare);
        assertEq(expenseSplitter.getClaimableShare(MEMBER), expectedShare);
    }
}
