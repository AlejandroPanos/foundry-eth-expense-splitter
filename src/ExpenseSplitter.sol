// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ExpenseSplitter {
    /* Errors */
    error ExpenseSplitter__YouAreNotTheOwner();
    error ExpenseSplitter__UserIsAMemberAlready();

    /* Type declarations */

    /* State variables */
    address public immutable i_owner;
    mapping(address => bool) s_isMember;
    mapping(address => uint256) s_claimableShare;
    address[] s_members;

    /* Events */
    event NewMember(address);

    /* Constructor */
    constructor() {
        i_owner = msg.sender;
    }

    /* Modifiers */
    modifier OnlyOwner() {
        require(msg.sender == i_owner);
        revert ExpenseSplitter__YouAreNotTheOwner();
        _;
    }

    /* Functions */
    /**
     * @dev Function follow CEI pattern.
     * @param _member is the address of the member to add.
     */
    function addMember(address _member) external OnlyOwner {
        // Check if user is a member already
        if (s_isMember[_member]) {
            revert ExpenseSplitter__UserIsAMemberAlready();
        }

        // Add new member
        s_isMember[_member] = true;
        s_members.push(_member);

        // Emit event
        emit NewMember(_member);
    }

    /* Getter functions */

    /* Receive & Fallback */
}
