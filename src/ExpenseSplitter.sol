// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract ExpenseSplitter {

    /* Errors */

    /* Type declarations */

    /* State variables */
    address public immutable i_owner;
    mapping(address => bool) s_isMember;
    mapping(address => uint256) s_claimableShare;
    address[] s_members;

    /* Events */

    /* Constructor */
    constructor() {
        i_owner = msg.sender;
    }

    /* Functions */

    /* Getter functions */

    /* Receive & Fallback */

}
