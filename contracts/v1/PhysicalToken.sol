// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract PhysicalToken is ERC1155, Ownable {

    event tradeUpdated(bytes32 indexed hashedImageId, TradeStatus status);

    enum TradeStatus {
        completed,
        created,
        accepted,
        returned
    }

    struct TradableItem {
        address payable from;
        address payable to;
        bool returnable;
        TradeStatus status;
        uint256 id;
        uint256 price;
        uint256 fromDeposit;
        uint256 toDeposit;
        uint256 toGas;
    }

    mapping(bytes32 => TradableItem) private tradableItemMap;

    constructor(address initialOwner) Ownable(initialOwner) ERC1155("https://<<URL placeholder>>/api/item/{id}.json") {
    }

    function toUint256(bytes memory _bytes, uint256 i) internal pure returns (uint256 value) {
        uint256 cursor = 32 * (2+i);
        assembly {
          value := mload(add(_bytes, cursor))
        }
    }

    function hash(uint256 id) internal view returns (bytes32 value) {
        return keccak256(abi.encodePacked(id, address(this)));
    }

    function getTradableItem(uint256 imageId) external view returns (address from, address to, TradeStatus status, uint256 id, uint256 price, uint256 fromDeposit, uint256 toDeposit, uint256 toGas, bool returnable) {
        TradableItem memory trade = tradableItemMap[hash(imageId)];
        return (trade.from, trade.to, trade.status, trade.id, trade.price, trade.fromDeposit, trade.toDeposit, trade.toGas, trade.returnable);
    }

    function mintTradableItem(uint256[] calldata imageIds, address[] calldata tos, uint256 id) external onlyOwner {
        require(imageIds.length == tos.length, "1");//number of image id and recipents not matched
        bytes32[] memory keys = new bytes32[](imageIds.length);
        for(uint256 i; i < imageIds.length; i++) {
            keys[i] = hash(imageIds[i]);
            require(tradableItemMap[keys[i]].id == 0, "2");//image id already exist
        }
        for(uint256 i; i < imageIds.length; i++) {
            tradableItemMap[keys[i]] = TradableItem(payable(tos[i]), payable(address(0)),false, TradeStatus.completed, id, 0, 0, 0, 0);
            _mint(tos[i], id, 1, "");
        }
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public override {
        require(amount == 1, "3");//only support amount = 1
        require(data.length == 32, "4");//data is not image id
        TradableItem storage trade = tradableItemMap[hash(toUint256(data, 0))];
        require(trade.status == TradeStatus.completed, "5");//item has imcompleted trade
        require(trade.from == from, "6");//is not item owner
        ERC1155.safeTransferFrom(from, to, id, amount, data);
        trade.from = payable(to);
    }

    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public override {
        require(false, "7");//disabled safeBatchTransferFrom
        // require(ids.length == data.length/32, "8");//data is not image id
        // bytes32[] memory key = new bytes32[](ids.length);
        // for(uint256 i; i < ids.length; i++) {
        //     key[i] = hash(toUint256(data, i));
        //     TradableItem memory trade = tradableItemMap[key[i]];
        //     require(trade.status == TradeStatus.completed, "9");//item has imcompleted trade
        //     require(trade.from == from, "a");//is not item owner
        //     require(amounts[i] == 1, "b");//only support amount = 1
        // }
        // for(uint256 i; i < ids.length; i++) {
        //     tradableItemMap[key[i]].from = payable(to);
        // }
        ERC1155.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function fromCreateTrade(uint256 imageId, address to, uint256 price, bool returnable) payable external returns (bytes32 hashId) {
        TradableItem storage trade = tradableItemMap[hash(imageId)];
        require(trade.from == msg.sender, "c");//sender is not item owner
        require(to != address(0) && to != msg.sender, "d");//to is either zero or self
        require(balanceOf(msg.sender, trade.id) > 0, "e");//erc1155 item not owned by from
        if (price == 0) {
            require(trade.status == TradeStatus.completed || trade.status == TradeStatus.created, "f");//cannot transfer a ongoing trade
            if (trade.status == TradeStatus.created) { //set free transfer to a created trade will immediate release deposit
                trade.status = TradeStatus.completed;
                if (trade.fromDeposit > 0) {
                    uint256 fromDeposit = trade.fromDeposit;
                    trade.fromDeposit = 0;
                    trade.from.transfer(fromDeposit);
                }
                if (trade.toDeposit > 0) {
                    uint256 toDeposit = trade.toDeposit;
                    trade.toDeposit = 0;
                    trade.to.transfer(toDeposit);
                }
            }
            ERC1155.safeTransferFrom(address(trade.from), to, trade.id, 1, "");
            trade.from = payable(to);
            return bytes32(0);
        } else {
            if (price >= trade.price) { //settle from deposit
                require(price == (trade.fromDeposit + msg.value), "g");//deposit value is not equal to price
                trade.fromDeposit += msg.value;
            } else { //return exceeded from deposit if new price is less than old
                uint256 fromDeposit = trade.fromDeposit;
                trade.fromDeposit = price;
                trade.from.transfer(fromDeposit + price - trade.price);
            }
//            modified by czw
//            last version code is if (trade.toDeposit + trade.toGas>0)
//            it would cause trade pay togas every trade
            if (trade.toDeposit>0 && trade.toGas>0) { //pay to gas fee by from deposit
                uint256 toDeposit = trade.toDeposit;
                uint256 toGas = trade.toGas;
                trade.fromDeposit -= toGas;
                trade.toDeposit = 0;
                trade.toGas = 0;
                trade.to.transfer(toDeposit + toGas);
            }
            if (trade.from != trade.to &&
                address(trade.to) != to &&
                address(trade.to) != address(0)) { //update to
                setApprovalForAll(trade.to, false);
            }
            trade.price = price;
            trade.status = TradeStatus.created;
            trade.to = payable(to);
            trade.returnable = returnable;
            setApprovalForAll(to, true); //approve to for toAcceptTrade
            bytes32 hashedImageId = hash(imageId);
            emit tradeUpdated(hashedImageId, TradeStatus.created);
            return hashedImageId;
        }
    }

    function cancelTrade(bytes32 hashedImageId) external {
        TradableItem storage trade = tradableItemMap[hashedImageId];
        require(trade.from == msg.sender || trade.to == msg.sender, "h");//not permissible to cancel this trade
        if (trade.status == TradeStatus.created || (trade.from == msg.sender && trade.status == TradeStatus.accepted)) {
            trade.status = TradeStatus.completed;
            uint256 fromDeposit = trade.fromDeposit;
            uint256 toDeposit = trade.toDeposit;
            uint256 toGas = trade.toGas;
            trade.fromDeposit = 0;
            trade.from.transfer(fromDeposit - trade.toGas);
            if(toDeposit + toGas > 0){
                trade.toDeposit = 0;
                trade.toGas = 0;
                trade.to.transfer(toDeposit + toGas);
            }
            trade.price = 0;
            emit tradeUpdated(hashedImageId, TradeStatus.completed);
        } else {
            require(false);//"cannot cancel a completed/accepted/returned trade"
        }
    }

    function toAcceptTrade(
        bytes32 hashedImageId
        ) payable external {
        uint256 startGas = gasleft();
        TradableItem storage trade = tradableItemMap[hashedImageId];
        require(trade.status == TradeStatus.created, "j");//can only accept created trade
        require(trade.fromDeposit + trade.price == trade.toDeposit + msg.value, "k");
        require(trade.to == msg.sender, "l");//not permissible to trade this item
        require(balanceOf(trade.from, trade.id) > 0, "m");//erc1155 item not owned by from
        trade.toDeposit += msg.value;
        trade.status = TradeStatus.accepted;
        emit tradeUpdated(hashedImageId, TradeStatus.accepted);
        trade.toGas = (startGas - gasleft()) * tx.gasprice;
    }

    function toCompleteTrade(
        uint256 imageId
        ) payable external {
        bytes32 hashedImageId = hash(imageId);
        TradableItem storage trade = tradableItemMap[hashedImageId];
        require(balanceOf(trade.from, trade.id) > 0, "n");//item not owned by sender
        require(trade.to == msg.sender, "o");//not permissible to trade this item
        if (trade.status == TradeStatus.created) {
            require(trade.price == msg.value, "p");//payment value is not equal to price
            trade.status = TradeStatus.completed;
        } else if (trade.status == TradeStatus.accepted) {
            trade.status = TradeStatus.completed;
            uint256 toDeposit = trade.toDeposit;
            trade.toDeposit = 0;
            trade.to.transfer(toDeposit - trade.price);
        } else {
            require(false);//cannot complete a completed/returned trade
        }
        uint256 fromDeposit = trade.fromDeposit;
        trade.fromDeposit = 0;
        trade.from.transfer(fromDeposit + trade.price);
        ERC1155.safeTransferFrom(address(trade.from), address(trade.to), trade.id, 1, "");
        trade.from = trade.to;
        trade.price = 0;
        emit tradeUpdated(hashedImageId, TradeStatus.completed);
    }

    function returnTrade(uint256 imageId) external {
        bytes32 hashedImageId = hash(imageId);
        TradableItem storage trade = tradableItemMap[hashedImageId];
        require(trade.from == msg.sender || trade.to == msg.sender, "s");//not permissible to return this trade
        require(trade.returnable, "t");
        if (trade.to == msg.sender && trade.status == TradeStatus.accepted) {
            trade.status = TradeStatus.returned;
            emit tradeUpdated(hashedImageId, TradeStatus.returned);
        } else if (trade.from == msg.sender && trade.status == TradeStatus.returned) {
            uint256 toDeposit = trade.toDeposit;
            trade.toDeposit = 0;
            trade.toGas = 0;
            trade.to.transfer(toDeposit);
            trade.status = TradeStatus.completed;
            uint256 fromDeposit = trade.fromDeposit;
            trade.fromDeposit = 0;
            trade.from.transfer(fromDeposit);
            trade.price = 0;
            emit tradeUpdated(hashedImageId, TradeStatus.completed);
        } else {
            require(false);//cannot return a completed/created trade
        }
    }
}
