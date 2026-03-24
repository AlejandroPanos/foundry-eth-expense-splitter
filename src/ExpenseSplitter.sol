// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ExpenseSplitter {
    /* Errors */
    error ExpenseSplitter__YouAreNotTheOwner();
    error ExpenseSplitter__UserIsAMemberAlready();
    error ExpenseSplitter__YouAreNotAMember();
    error ExpenseSplitter__NotEnoughEth();
    error ExpenseSplitter__NoMembers();
    error ExpenseSplitter__NoBalance();
    error ExpenseSplitter__TransferFailed();
    error ExpenseSplitter__YouHaveNoContribution();

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
    event FundsSplit(uint256, uint256);
    event ClaimDone(address);

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

    function splitFunds() external OnlyOwner {
        // Check if there are no members or balance is 0
        if (s_members.length == 0) {
            revert ExpenseSplitter__NoMembers();
        }

        if (address(this).balance == 0) {
            revert ExpenseSplitter__NoBalance();
        }

        // Check num. members and balance
        uint256 members = s_members.length;
        uint256 balance = address(this).balance;

        // Split the money equally
        uint256 share = balance / members;
        uint256 remainder = balance % members;

        // Pay the share to each member
        for (uint256 i = 0; i < s_members.length; i++) {
            s_claimableShare[s_members[i]] += share;
        }

        // Pay the owner the remainder
        (bool success,) = payable(i_owner).call{value: remainder}("");
        if (!success) {
            revert ExpenseSplitter__TransferFailed();
        }

        // Emit event
        emit FundsSplit(share, remainder);
    }

    function claim() external OnlyMembers {
        // Check if member has funds
        if (s_claimableShare[msg.sender] == 0) {
            revert ExpenseSplitter__YouHaveNoContribution();
        }

        // Run effects
        uint256 amount = s_claimableShare[msg.sender];
        s_claimableShare[msg.sender] = 0;

        // Pay them their amount
        (bool success,) = payable(msg.sender).call{value: amount}("");
        if (!success) {
            revert ExpenseSplitter__TransferFailed();
        }

        // Emit event
        emit ClaimDone(msg.sender);
    }

    /* Getter functions */

}
