// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title ExpenseSplitter
 * @author Alejandro Paños
 * @notice A group expense splitting contract. The owner adds members who
 * contribute ETH to a shared pool. The owner can split the accumulated
 * balance equally among all members at any time, and members can claim
 * their allocated share whenever they choose.
 * @dev Uses a pull payment pattern for fund distribution — members claim
 * their share rather than receiving it automatically, reducing reentrancy risk.
 * @dev Integer division remainder from the split is sent to the owner.
 */
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
    event NewContribution(uint256, address);
    event FundsSplit(uint256, uint256);
    event ClaimDone(address);

    /* Constructor */
    constructor() {
        i_owner = msg.sender;
    }

    /* Modifiers */
    /**
     * @notice Restricts function access to the contract owner.
     * @dev Reverts with ExpenseSplitter__YouAreNotTheOwner if the caller
     * is not the owner.
     * @dev Could also use the OpenZeppelin library and import the Ownable contract
     * instead of creating the modifier ourselves.
     */
    modifier OnlyOwner() {
        if (msg.sender != i_owner) {
            revert ExpenseSplitter__YouAreNotTheOwner();
        }
        _;
    }

    /**
     * @notice Restricts function access to registered members.
     * @dev Reverts with ExpenseSplitter__YouAreNotAMember if the caller
     * is not in the members mapping.
     */
    modifier OnlyMembers() {
        if (!s_isMember[msg.sender]) {
            revert ExpenseSplitter__YouAreNotAMember();
        }
        _;
    }

    /* Functions */
    /**
     * @notice Adds a new member to the expense group.
     * @param _member The address to add as a member.
     * @dev Only callable by the owner.
     * @dev Reverts if the address is already a member.
     * @dev Follows CEI — state is updated before emitting the event.
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

    /**
     * @notice Allows a member to contribute ETH to the shared pool.
     * @dev Only callable by registered members.
     * @dev The ETH sent must be at least MIN_AMOUNT (0.01 ether).
     * @dev Contributed funds accumulate in the contract until splitFunds()
     * is called by the owner.
     */
    function contribute() external payable OnlyMembers {
        // Check sender sends minimum amount
        if (msg.value < MIN_AMOUNT) {
            revert ExpenseSplitter__NotEnoughEth();
        }

        // Emit event
        emit NewContribution(msg.value, msg.sender);
    }

    /**
     * @notice Splits the contract balance equally among all members and
     * allocates each member's share for claiming.
     * @dev Only callable by the owner.
     * @dev Uses integer division — any remainder is sent directly to the owner.
     * @dev Allocated shares are stored in s_claimableShare and must be
     * claimed individually by each member via claim().
     * @dev Reverts if there are no members or the contract balance is zero.
     */
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
        for (uint256 i = 0; i < members; i++) {
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

    /**
     * @notice Allows a member to withdraw their allocated share.
     * @dev Only callable by registered members.
     * @dev Reverts if the caller has no claimable balance.
     * @dev Follows CEI — the claimable balance is zeroed before the
     * ETH transfer to prevent reentrancy.
     */
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
    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getMembersCount() external view returns (uint256) {
        return s_members.length;
    }

    function getClaimableShare(address _member) external view returns (uint256) {
        return s_claimableShare[_member];
    }

    function getIsMember(address _member) external view returns (bool) {
        return s_isMember[_member];
    }
}
