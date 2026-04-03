// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155GameFiLootbox is ERC1155 {
    address public owner;
    uint256 public boxPrice = 0.01 ether;
    mapping(uint256 => uint256) public itemWeights;

    constructor() ERC1155("ipfs://gamefi/") {
        owner = msg.sender;
        itemWeights[1] = 50;
        itemWeights[2] = 30;
        itemWeights[3] = 20;
    }

    function openLootbox() external payable {
        require(msg.value == boxPrice);
        uint256 random = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 100;
        uint256 itemId = random < 50 ? 1 : random < 80 ? 2 : 3;
        _mint(msg.sender, itemId, 1, "");
    }

    function mintAdmin(address to, uint256 id, uint256 amount) external {
        require(msg.sender == owner);
        _mint(to, id, amount, "");
    }
}
