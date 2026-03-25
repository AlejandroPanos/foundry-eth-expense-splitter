# ExpenseSplitter

A Solidity smart contract built as a Foundry practice project. An owner registers members, members contribute ETH to a shared pool, and the owner triggers an equal split when ready. Each member can then independently claim their allocated share. Any indivisible remainder goes to the owner.

---

## What It Does

- Owner registers wallet addresses as members
- Registered members can contribute ETH to the shared pool (minimum 0.01 ETH)
- Owner triggers a split that divides the pool equally among all members
- Indivisible remainder is sent directly to the owner at split time
- Each member claims their own allocated share independently
- Reverts with custom errors for access control violations and invalid states

---

## Project Structure

```
.
├── src/
│   └── ExpenseSplitter.sol             # Main contract
├── script/
│   └── DeployExpenseSplitter.s.sol     # Foundry deploy script
└── test/
    └── unit/
        └── TestExpenseSplitter.t.sol   # Unit tests
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

### Run tests with coverage report

```bash
forge coverage
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
| `MIN_AMOUNT`       | `uint256`                     | Minimum contribution amount (0.01 ETH)                 |

### Functions

| Function                     | Visibility         | Description                                                                                        |
| ---------------------------- | ------------------ | -------------------------------------------------------------------------------------------------- |
| `addMember(address _member)` | `external`         | Registers a new member. Owner only.                                                                |
| `contribute()`               | `external payable` | Adds ETH to the shared pool. Members only. Minimum 0.01 ETH.                                       |
| `splitFunds()`               | `external`         | Divides the pool equally among all members and sends the remainder to the owner. Owner only.       |
| `claim()`                    | `external`         | Sends the caller's claimable share to their wallet and resets their balance to zero. Members only. |
| `getOwner()`                 | `external view`    | Returns the owner address                                                                          |
| `getMembersCount()`          | `external view`    | Returns the total number of registered members                                                     |
| `getClaimableShare(address)` | `external view`    | Returns the claimable balance for a given address                                                  |
| `getIsMember(address)`       | `external view`    | Returns whether a given address is a registered member                                             |

### Modifiers

| Modifier      | Description                                      |
| ------------- | ------------------------------------------------ |
| `OnlyOwner`   | Reverts if the caller is not the owner           |
| `OnlyMembers` | Reverts if the caller is not a registered member |

### Custom Errors

| Error                                      | When It Triggers                                            |
| ------------------------------------------ | ----------------------------------------------------------- |
| `ExpenseSplitter__YouAreNotTheOwner()`     | A non-owner calls an owner-only function                    |
| `ExpenseSplitter__YouAreNotAMember()`      | A non-member calls a member-only function                   |
| `ExpenseSplitter__UserIsAMemberAlready()`  | Owner tries to register an address that is already a member |
| `ExpenseSplitter__NotEnoughEth()`          | A member contributes less than the minimum amount           |
| `ExpenseSplitter__NoMembers()`             | splitFunds() is called with no members registered           |
| `ExpenseSplitter__NoBalance()`             | splitFunds() is called with zero contract balance           |
| `ExpenseSplitter__YouHaveNoContribution()` | A member calls claim() with no allocated share              |
| `ExpenseSplitter__TransferFailed()`        | An ETH transfer via call() fails                            |

### Events

| Event                                             | When It Emits                              |
| ------------------------------------------------- | ------------------------------------------ |
| `NewMember(address member)`                       | A new member is successfully registered    |
| `NewContribution(uint256 amount, address member)` | A member successfully contributes ETH      |
| `FundsSplit(uint256 share, uint256 remainder)`    | Funds are successfully split among members |
| `ClaimDone(address member)`                       | A member successfully claims their share   |

---

## Tests

| Test                                            | What It Checks                                                                                    |
| ----------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `testOwnerIsMsgSender`                          | The contract owner is correctly set to the deployer                                               |
| `testOwnerCanAddMembers`                        | The owner can successfully add a member and the correct event is emitted                          |
| `testOnlyOwnerCanAddMembers`                    | A non-owner calling addMember() reverts with the correct error                                    |
| `testRevertsIfAddsExistingMember`               | Adding an already registered member reverts correctly                                             |
| `testRevertsIfContributionIsLessThanMinimum`    | Contributing below the minimum amount reverts correctly                                           |
| `testNonMemberCannotContribute`                 | An unregistered address calling contribute() reverts correctly                                    |
| `testContributingIncreasesContractBalance`      | A member contributing ETH increases the contract balance by the correct amount                    |
| `testSplitFundsGetsRightAmount`                 | After a split, each member's claimable share equals the total balance divided by the member count |
| `testMemberClaimsAndBalanceResetsToZero`        | A member claiming their share resets their claimable balance to zero                              |
| `testRevertsIfMemberHasNoContributionAndClaims` | A member with no claimable share calling claim() reverts correctly                                |
| `testSplitFundsRevertsIfNoMembersAdded`         | splitFunds() reverts when no members are registered                                               |
| `testSplitFundsRevertsIfNoBalanceInContract`    | splitFunds() reverts when the contract balance is zero                                            |

---
