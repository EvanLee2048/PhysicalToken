# Technical Documentation

## Overview
The `PhysicalToken` smart contract is an implementation of the ERC1155 multi-token standard with additional functionalities for managing tradable items, specifically for facilitating trades between users. The below diagram illustrates the smart contract architecture:

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

| Function | Caller | Description |
|----------|----------|----------|
|**mintTradableItem** | Contract Owner|Mints new tradable items and assigns them to specified addresses. This function is only callable by contract owner. It is public just because to allow the owner to deploy the contract first and mint at later time. |
|**getTradableItem**| Everyone | Retrieves details of a tradable item based on its image ID|
|**safeTransferFrom**| Seller | Overrides the ERC1155 transfer function to include trade validation|
|**fromCreateTrade**| Seller |Initiates a trade from the seller to a buyer, including price and if the seller accept returning the product in trading procuess|
|**cancelTrade**| Buyer or Seller | Buyer or seller cancel an imcomplete trade |
|**toAcceptTrade**| Buyer | Accepts a trade by the buyer, ensuring the deposits match the trade price|
|**toCompleteTrade**| Seller |Completes a trade, transferring the item and handling deposits|
|**returnTrade**| Buyer | Manages the return process for a trade, including refunding deposits|

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

Smart contracts deployed to blockchain are immutable by nature. However, contract upgrade is possible by implementing transparent proxy pattern. The **Physical Token** project leverages the open-source implementation by [Open Zeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts/tree/master).

The behavior for the use of contract are:

| Behavior | Description |
|----------|----------|	
| Proxy admin triggers the functions | The Proxy admin can access the administrative functions directly but never fall back to the implementation contract. |
| Everyone who is not proxy admin | Any function calls will be directed to the underlying implementation contract, regardless of whether those calls correspond to the administrative functions exposed by the proxy itself. |

## Contract Security
The **Physcial Token** contract owner has the administrative permission to perform critical action (e.g. mint token & contract upgrade "by proxy admin"). The security measure for the administrative persmissions are crucial to the development of eco-system. The **Physcial Token** project protects the critical actions by implementing multi-signature smart contract pattern. The **Physcial Token** use Safe.Global (a.k.a Gnosis Safe) [multi-signature solution](https://github.com/safe-global/safe-deployments) to protect the **Physcial Token**.

The **Physcial Token** contract administrative action only executed with 3 of 2 approval signature is obtained. The 3 signature keys are managed in different key management system, which can be self-managed HSM or manged by custodian.

## Future Enhancement

### Tokenomics
The **physical token** wasn't consider tokenomics model such as DAO. Potentially, the physical token solution is possible to issue DAO token as incentive and establish community goverance.

### Use of Stablecoin 
The **physical token** smart contract only support native cryptocurrency (e.g. Polygon Matic) as payment & collateralization for the trade. To mitigate market risk of rigorous fluctuation of native cryptocurrency. The smart contract should accept stablecoin like USDC or PUSD.

### Gas Abstraction
The **physical token** project target user are gamers or flipper. They are not necessarily familiar with blockchain. The project should provider gas abstraction feature so that the user can pay gas fee using stablecoin.

### Cross Chain Transfer
The **physical token** was only designed for Polygon Matic at the moment. However, the team should study the technical feasibility for the support of cross chain transfer.

### Security by MPC Wallet
Comparing to multi-sig smart contract approach, the MPC wallet solution itself doesn't consist of smart contract. The MPC wallet solution implies:
1. For future evm compatible blockchain deployment, less smart contract is required to deploy. The **Physical Token** architecture can be simplified. The  operation cost can be reduced (both for contract deployment and function execute gas fee).
2. MPC Wallet solution can be directly adopted by non-evm compitable contract deployment.
