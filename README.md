# Project Background

The **Physical Token** aim to partner with gaming industry and intellectual property (IP) owner to issue gaming NFT (e.g. Skin) along with limited supply physical merchandise (e.g. Limited Edition Game Card, Toy Figure). The firm "embed" NFT on physcial merchandise using patented anti-counterfiet 2D bar code:


![Anti-Counterfeit Code Sample](https://github.com/EvanLee2048/PhysicalToken/blob/master/img/Anti-Counterfeit%20Code%20Sample.png?raw=true)

The **Physical Token** smart contract is an implementation of the ERC1155 which represent the limited supply of NFT along with the physical merchandise. It enhances the ERC1155 functionality to establish decentralized P-to-P trading eco-system. The eco-system benefits the stakeholders in the entire industries.

The project idea is initiated in 2022. It won't be a surprise to the contributor if there similiar solution in market later time. 
### Incentive
The **Physical Token** is designed to provide incentive of use to the stakeholders:
| Stakeholders | Incentive |
|----------|----------|
| Physcial NFT Buyer & Seller | With the anti-counterfiet 2D bar code, The physical product and the NFT are bundle as atomic product. Buyer & Seller will trade the phycical product and NFT as a bundle to avoid lost of value.<br> The decentralized P-to-P trading ecosystem enables: <br>1. Automated goverance for P-to-P trading <br>2. trading activities such as Bidding and Auction | 
| Intellectual property (IP) owner | Their are arbitrage activity for limited supplied products. In extreme cases, the flipper even make more revenue than the IP owner. <br> The **Physical Token** smart contract allows IP owner to charge trading fee for arbitrage activity. The **Physical Token** provides a new source of revenue for IP owner | 


# Functional Walkthrough


The flow diagram illustrates a end-to-end trading process in **Physical Token**:

![Physical Token](https://github.com/EvanLee2048/PhysicalToken/blob/master/img/Physical%20Token.png?raw=true)

Here is a high-level description of how the product operates:


## Step 1 - Seller Creates Trade

1. **Seller Scans Image**: The seller starts by scanning the image of the item to be traded.
2. **Set Price**: If the price is greater than zero, the seller deposits native token as collateral.
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

There are 3 scenario for completion of trade.

| Scenario | Description |
|----------|----------|
| Accept the item   | **Buyer Scans Image**: The buyer scans the image to complete the trade.<br>**Transfer Ownership**: If the status is "accepted," ownership is transferred to the buyer, and the seller receives the price and deposit back.<br>**Status Update**: The trade status is set to "completed."   |
| Buyer returning the item    | **Buyer Scans Image**: The buyer scans the image to return the item if they choose to. <br>**Status Check**: If the item is eligible for return, the status is updated, and the trade is reversed.   |
| Seller returning the item    | **Seller Scans Image**: The seller scans the image to initiate a return. <br> **Refunds and Transfers**: The buyer's deposit is refunded, and the seller's deposit is returned. Ownership is transferred back to the seller.   |
| Cancelling the Trade    | Either the seller or buyer can cancel the trade:<br>**Enter Image ID**: The requester enters the hashed image ID.<br>**Refunds**: Deposits and gas fees are refunded to the respective parties based on trade status.   |
| Changing the trade item    | The seller has the option to change the trade's details before it is accepted by the buyer.  |

## Step 6 : Re-Selling the Item (Go back Step 1)

After a trade is completed or cancelled, the seller can re-sell the item by creating a new trade.

# Technical Documentation
The technical documentation for **Physical Token** is in [here](contracts/v1/README.md).

# Disclaimer
As of 2024, This repository is not in active maintenance. The contributor do not guarantee the functionality and the stability for the solution.

# License
This project is licensed under the GPLv3 License.
