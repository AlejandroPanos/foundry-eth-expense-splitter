// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ExpenseSplitter {
    /* Errors */
    error ExpenseSplitter__YouAreNotTheOwner();
    error ExpenseSplitter__UserIsAMemberAlready();
    error ExpenseSplitter__YouAreNotAMember();
    error ExpenseSplitter__NotEnoughEth();

    /* Type declarations */

    /* State variables */
    address public immutable i_owner;
    uint256 public constant MIN_AMOUNT = 0.01 ether;
    mapping(address => bool) s_isMember;
    mapping(address => uint256) s_claimableShare;
    address[] s_members;

    /* Events */
    event NewMember(address);
    event NewContribution(address);

    /* Constructor */
    constructor() {
        i_owner = msg.sender;
    }

    /* Modifiers */
    modifier OnlyOwner() {
        if (msg.sender != i_owner) {
            revert ExpenseSplitter__YouAreNotTheOwner();
        }
        _;
    }

    modifier OnlyMembers() {
        if (!s_isMember[msg.sender]) {
            revert ExpenseSplitter__YouAreNotAMember();
        }
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

    function contribute() external payable OnlyMembers {
        // Check sender sends minimum amount
        if (msg.value < MIN_AMOUNT) {
            revert ExpenseSplitter__NotEnoughEth();
        }

        // Update the senders balance
        s_claimableShare[msg.sender] += msg.value;

        // Emit event
        emit NewContribution(msg.sender);
    }

    /* Getter functions */

    /* Receive & Fallback */
}
