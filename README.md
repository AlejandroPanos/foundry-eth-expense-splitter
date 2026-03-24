# ExpenseSplitter

A beginner-friendly Solidity smart contract built as a Foundry practice project. An owner registers members, members contribute ETH to a shared pool, and the owner triggers an equal split when ready. Each member can then claim their allocated share independently.

---

## What It Does

- Owner registers wallet addresses as members
- Registered members can contribute ETH to the shared pool
- Owner triggers a split that divides the pool equally among all members
- Each member claims their own share independently
- Reverts with custom errors for access control violations and invalid states

---

## Project Structure

```
.
├── src/
│   └── ExpenseSplitter.sol         # Main contract
├── script/
│   └── DeployExpenseSplitter.s.sol # Foundry deploy script
└── test/
    └── ExpenseSplitterTest.t.sol   # Unit tests
```

---

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed

### Install dependencies and build

```bash
forge install
forge build
```

### Run tests

```bash
forge test
```

### Run tests with gas report

```bash
forge test --gas-report
```

### Deploy to a local Anvil chain

In one terminal, start Anvil:

```bash
anvil
```

In another terminal, run the deploy script:

```bash
forge script script/DeployExpenseSplitter.s.sol --rpc-url http://localhost:8545 --broadcast
```

---

## Contract Overview

### State

| Variable           | Type                          | Description                                            |
| ------------------ | ----------------------------- | ------------------------------------------------------ |
| `i_owner`          | `address`                     | Immutable owner address set at deployment              |
| `s_members`        | `address[]`                   | Array of all registered member addresses               |
| `s_isMember`       | `mapping(address => bool)`    | Tracks whether an address is a registered member       |
| `s_claimableShare` | `mapping(address => uint256)` | Tracks each member's claimable ETH share after a split |

### Functions

| Function                     | Visibility         | Description                                                       |
| ---------------------------- | ------------------ | ----------------------------------------------------------------- |
| `addMember(address _member)` | `external`         | Registers a new member. Owner only.                               |
| `contribute()`               | `external payable` | Adds ETH to the shared pool. Members only.                        |
| `splitFunds()`               | `external`         | Divides the pool equally among all members. Owner only.           |
| `claim()`                    | `external`         | Sends the caller's claimable share to their wallet. Members only. |
| `getClaimableShare(address)` | `external view`    | Returns the claimable balance for a given address                 |
| `getIsMember(address)`       | `external view`    | Returns whether a given address is a registered member            |
| `getMemberCount()`           | `external view`    | Returns the total number of registered members                    |

### Custom Errors

| Error                               | When It Triggers                                            |
| ----------------------------------- | ----------------------------------------------------------- |
| `ExpenseSplitter__NotOwner()`       | A non-owner calls an owner-only function                    |
| `ExpenseSplitter__NotMember()`      | A non-member calls a member-only function                   |
| `ExpenseSplitter__AlreadyMember()`  | Owner tries to register an address that is already a member |
| `ExpenseSplitter__NoMembers()`      | splitFunds() is called with no members registered           |
| `ExpenseSplitter__NoBalance()`      | splitFunds() is called with zero contract balance           |
| `ExpenseSplitter__NothingToClaim()` | A member calls claim() with no allocated share              |
| `ExpenseSplitter__TransferFailed()` | The ETH transfer in claim() fails                           |

---

## Tests

| Test                                      | What It Checks                                                                            |
| ----------------------------------------- | ----------------------------------------------------------------------------------------- |
| `testOnlyOwnerCanAddMember`               | A non-owner calling addMember() reverts with the correct error                            |
| `testNonMemberCannotContribute`           | An unregistered address calling contribute() reverts                                      |
| `testContributeIncreasesContractBalance`  | A member contributing ETH increases the contract's balance correctly                      |
| `testSplitFundsCalculatesSharesCorrectly` | After a split, each member's claimable share equals total balance divided by member count |
| `testMemberCanClaimShare`                 | A member claiming their share receives the ETH and their claimable balance resets to zero |

---
