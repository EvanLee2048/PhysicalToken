# Technical Documentation

## Overview

The `PhysicalToken` smart contract is an implementation of the ERC1155 multi-token standard with additional functionalities for managing tradable items, specifically for facilitating trades between users. The diagram below illustrates the smart contract architecture:

![Smart Contract Architecture](https://github.com/EvanLee2048/PhysicalToken/blob/master/img/Smart%20Contract%20Architecture.png?raw=true)

## Contract `PhysicalToken`

This contract extends `ERC1155` and `Ownable` to manage the trading of physical tokens represented as ERC1155 tokens.

### Dependency

- **ERC1155**: Implements the ERC1155 multi-token standard.
- **Ownable**: Provides ownership management for the contract.

### Events

- **tradeUpdated**: Emitted whenever there's a change in the trade status of an item.

### Enums

- **TradeStatus**: Represents the various stages of a trade (`completed`, `created`, `accepted`, `returned`).

### Structs

- **TradableItem**: Represents the details of a tradable item including:
  - `from` and `to`: Addresses of the sender and receiver.
  - `returnable`: Indicates if the item can be returned.
  - `status`: Current status of the trade.
  - `id`: Token ID.
  - `price`: Price of the item.
  - `fromDeposit` and `toDeposit`: Deposits by the sender and receiver, respectively.
  - `toGas`: Gas fee paid by the receiver.

### State Variables

- **tradableItemMap**: A mapping from a hashed image ID to a `TradableItem`.

### Constructor

- Initializes the ERC1155 base contract with a metadata URI.

## Internal Functions

- **toUint256**: Converts a segment of a byte array to a `uint256`.
- **hash**: Generates a hash for an item ID and the contract address.

## Public Functions

| Function              | Caller         | Description                                                                 |
|-----------------------|----------------|-----------------------------------------------------------------------------|
| **mintTradableItem**  | Contract Owner | Mints new tradable items and assigns them to specified addresses. This function is only callable by the contract owner. It is public to allow the owner to deploy the contract first and mint at a later time. |
| **getTradableItem**   | Everyone       | Retrieves details of a tradable item based on its image ID.                 |
| **safeTransferFrom**  | Seller         | Overrides the ERC1155 transfer function to include trade validation.        |
| **fromCreateTrade**   | Seller         | Initiates a trade from the seller to a buyer, including price and if the seller accepts returning the product in the trading process. |
| **cancelTrade**       | Buyer or Seller| Allows the buyer or seller to cancel an incomplete trade.                   |
| **toAcceptTrade**     | Buyer          | Accepts a trade by the buyer, ensuring the deposits match the trade price.  |
| **toCompleteTrade**   | Seller         | Completes a trade, transferring the item and handling deposits.             |
| **returnTrade**       | Buyer          | Manages the return process for a trade, including refunding deposits.       |

## Modifiers

- **onlyOwner**: Restricts certain functions to the contract owner.

## Usage Example

1. **Minting Items**: The contract owner mints new items and assigns them to users.
2. **Creating a Trade**: A user initiates a trade by specifying the recipient, price, and whether the item is returnable.
3. **Accepting a Trade**: The recipient accepts the trade, which involves validating deposits.
4. **Completing a Trade**: The recipient completes the trade, finalizing the transfer and handling deposits.
5. **Returning a Trade**: Either party can manage the return process if the item is returnable.

## Error Messages

Custom error messages are provided for various conditions, ensuring clear communication of issues such as mismatched deposits, unauthorized actions, or invalid states.

## Notes

- **Approval Management**: The contract uses `setApprovalForAll` to manage approvals for trade actions.
- **Gas Management**: The contract accounts for gas fees in deposit handling to ensure fair compensation.

This contract provides a robust framework for managing tradable items on the Ethereum blockchain, leveraging the ERC1155 standard while adding custom logic for trade facilitation and deposit management.

## Contract Upgradeability

Smart contracts deployed to the blockchain are immutable by nature. However, contract upgrades are possible by implementing the transparent proxy pattern. The **Physical Token** project leverages the open-source implementation by [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master).

The behavior for the use of the contract is:

| Behavior                          | Description                                                                 |
|-----------------------------------|-----------------------------------------------------------------------------|
| Proxy admin triggers the functions | The Proxy admin can access the administrative functions directly but never fallback to the implementation contract. |
| Everyone who is not proxy admin    | Any function calls will be directed to the underlying implementation contract, regardless of whether those calls correspond to the administrative functions exposed by the proxy itself. |

## Contract Security

The **Physical Token** contract owner has the administrative permission to perform critical actions (e.g., mint token & contract upgrade "by proxy admin"). The security measures for the administrative permissions are crucial to the development of the ecosystem. The **Physical Token** project protects the critical actions by implementing a multi-signature smart contract pattern. The **Physical Token** uses Safe.Global (a.k.a Gnosis Safe) [multi-signature solution](https://github.com/safe-global/safe-deployments) to protect the **Physical Token**.

The **Physical Token** contract administrative actions are only executed with 3 of 2 approval signatures obtained. The 3 signature keys are managed in different key management systems, which can be self-managed HSM or managed by a custodian.

## Future Enhancements

### Tokenomics

The **Physical Token** project did not consider a tokenomics model such as DAO. Potentially, the Physical Token solution could issue DAO tokens as incentives and establish community governance.

### Use of Stablecoin

The **Physical Token** smart contract only supports native cryptocurrency (e.g., Polygon Matic) as payment & collateralization for the trade. To mitigate the market risk of rigorous fluctuation of native cryptocurrency, the smart contract should accept stablecoins like USDC or PUSD.

### Gas Abstraction

The **Physical Token** project targets users such as gamers or flippers, who may not be familiar with blockchain. The project should provide a gas abstraction feature so that the user can pay gas fees using stablecoins.

### Cross-Chain Transfer

The **Physical Token** was only designed for Polygon Matic at the moment. However, the team should study the technical feasibility of supporting cross-chain transfers.

### Security by MPC Wallet

Comparing to the multi-sig smart contract approach, the MPC wallet solution itself doesn't consist of a smart contract. The MPC wallet solution implies:
1. For future EVM-compatible blockchain deployment, less smart contract deployment is required. The **Physical Token** architecture can be simplified, reducing operational costs (both for contract deployment and function execution gas fees).
2. The MPC Wallet solution can be directly adopted by non-EVM-compatible contract deployments.
