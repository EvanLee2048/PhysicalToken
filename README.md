# Project Background

The **Physical Token** aims to partner with the gaming industry and intellectual property (IP) owners to issue gaming NFTs (e.g. Skins) along with limited supply physical merchandise (e.g. Limited Edition Game Cards, Toy Figures). It is assumed that NFTs are "attached" to physical merchandise using patented anti-counterfeit 2D barcodes:

![Anti-Counterfeit Code Sample](https://github.com/EvanLee2048/PhysicalToken/blob/master/img/Anti-Counterfeit%20Code%20Sample.png?raw=true)

The **Physical Token** smart contract is an implementation of ERC1155, which represents the limited supply of NFTs along with the physical merchandise. It enhances the ERC1155 functionality to establish a decentralized P-to-P trading ecosystem. The ecosystem benefits the stakeholders in the entire industry.

The project idea was initiated in 2022. It won't be a surprise to the contributors if there are similar solutions in the market later on.

### Incentive

The **Physical Token** is designed to provide incentives for use to the stakeholders:

| Stakeholders | Incentive |
|--------------|-----------|
| Physical NFT Buyer & Seller | With the anti-counterfeit 2D barcodes, the physical product and the NFT are bundled as an atomic product. Buyers & Sellers will trade the physical product and NFT as a bundle to avoid loss of value.<br> The decentralized P-to-P trading ecosystem enables:<br>1. Automated governance for P-to-P trading<br>2. Trading activities such as Bidding and Auction |
| Intellectual Property (IP) Owner | There are arbitrage activities for limited supply products. In extreme cases, the flippers even make more revenue than the IP owner.<br> The **Physical Token** smart contract allows IP owners to charge trading fees for arbitrage activities. The **Physical Token** provides a new source of revenue for IP owners |

# Functional Walkthrough

The flow diagram illustrates an end-to-end trading process in **Physical Token**:

![Physical Token](https://github.com/EvanLee2048/PhysicalToken/blob/master/img/Physical%20Token.png?raw=true)

Here is a high-level description of how the product operates:

## Step 1 - Seller Creates Trade

1. **Seller Scans Image**: The seller starts by scanning the image of the item to be traded.
2. **Set Price**: If the price is greater than zero, the seller deposits native tokens as collateral.
3. **Trade Creation**: If all conditions are met, the item's status is set to "created," and token ownership is transferred to the system.

## Step 2 - Buyer Accepts Trade

1. **Buyer Scans Image**: The buyer scans the image of the item to accept the trade.
2. **Deposit Collection**: The buyer deposits the trade price and a deposit (1.1 in this case).
3. **Status Update**: The trade status is set to "accepted," and gas fees are saved for the buyer.

## Step 3 - Seller Delivers Item

The seller delivers the item to the buyer after the trade is accepted.

## Step 4 - Buyer Receives Item

The buyer confirms receipt of the item. The status changes, and the buyer's deposit is updated accordingly.

## Step 5 - Completing the Trade

There are 3 scenarios for the completion of trade:

| Scenario | Description |
|----------|-------------|
| Accept the item | **Buyer Scans Image**: The buyer scans the image to complete the trade.<br>**Transfer Ownership**: If the status is "accepted," ownership is transferred to the buyer, and the seller receives the price and deposit back.<br>**Status Update**: The trade status is set to "completed." |
| Buyer returning the item | **Buyer Scans Image**: The buyer scans the image to return the item if they choose to.<br>**Status Check**: If the item is eligible for return, the status is updated, and the trade is reversed. |
| Seller returning the item | **Seller Scans Image**: The seller scans the image to initiate a return.<br> **Refunds and Transfers**: The buyer's deposit is refunded, and the seller's deposit is returned. Ownership is transferred back to the seller. |
| Cancelling the Trade | Either the seller or buyer can cancel the trade:<br>**Enter Image ID**: The requester enters the hashed image ID.<br>**Refunds**: Deposits and gas fees are refunded to the respective parties based on trade status. |
| Changing the trade item | The seller has the option to change the trade's details before it is accepted by the buyer. |

## Step 6: Re-Selling the Item (Go back to Step 1)

After a trade is completed or cancelled, the seller can re-sell the item by creating a new trade.

# Technical Documentation

The technical documentation for **Physical Token** is [here](contracts/v1/README.md).

# Disclaimer

As of 2024, this repository is not in active maintenance. The contributors do not guarantee the functionality and stability of the solution.

# License

This project is licensed under the GPLv3 License.
