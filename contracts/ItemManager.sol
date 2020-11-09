// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable {

  enum SupplyChainStatuses {Created, Paid, Delivered}

  struct SupplyChainItem {
    Item item;
    string identifier;
    SupplyChainStatuses status;
  }

  mapping(uint => SupplyChainItem) public items;
  uint index;

  event SupplyChainEvent(uint _index, uint _status, address _address);

  function createItem(string memory _identifier, uint _priceInWei) public onlyOwner {
    Item item = new Item(this, _priceInWei, index);
    items[index].item = item;
    items[index].identifier = _identifier;
    items[index].status = SupplyChainStatuses.Created;
    emit SupplyChainEvent(index, uint(items[index].status), address(item));
    index++;
  }

  function triggerPayment(uint _index) public payable {
    Item item = items[_index].item;
    require(address(item) == msg.sender, "Only items are allowed to update themselves");
    require(item.priceInWei() <= msg.value, "Item is not fully paid");
    require(items[_index].status == SupplyChainStatuses.Created, "Item is further in the supply chain");
    items[_index].status = SupplyChainStatuses.Paid;
    emit SupplyChainEvent(_index, uint(items[_index].status), address(item));
  }

  function triggerDelivery(uint _index) public onlyOwner {
    require(items[_index].status == SupplyChainStatuses.Paid, "Item is further in the supply chain");
    items[_index].status = SupplyChainStatuses.Delivered;
    emit SupplyChainEvent(_index, uint(items[_index].status), address(items[_index].item));
  }
}
