// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./ItemManager.sol";

contract Item {
  uint public priceInWei;
  uint public paidWei;
  uint public index;

  ItemManager parentContract;

  constructor(ItemManager _parentContract, uint _priceInWei, uint _index) public {
    parentContract = _parentContract;
    priceInWei = _priceInWei;
    index = _index;
  }

  receive() external payable {
    require(priceInWei <= msg.value, "Item is not fully paid");
    require(paidWei == 0, "Item is already paid");
    paidWei += msg.value;
    (bool success, ) = address(parentContract).call{value: msg.value}(
      abi.encodeWithSignature("triggerPayment(uint256)", index)
    );
    require(success, "Payment did not work");
  }

  fallback() external {}
}
