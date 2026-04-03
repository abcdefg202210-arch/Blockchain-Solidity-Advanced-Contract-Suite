// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract MultiChainNFTBridge {
    address public validator;
    mapping(bytes32 => bool) public processed;

    event NFTBridgeSent(address indexed user, uint256 destChain, uint256 tokenId);
    event NFTBridgeReceived(address indexed user, uint256 tokenId);

    constructor() {
        validator = msg.sender;
    }

    function sendNFT(address nft, uint256 tokenId, uint256 destChain) external {
        IERC721(nft).transferFrom(msg.sender, address(this), tokenId);
        bytes32 id = keccak256(abi.encodePacked(msg.sender, nft, tokenId, destChain));
        emit NFTBridgeSent(msg.sender, destChain, tokenId);
    }

    function receiveNFT(address user, address nft, uint256 tokenId, bytes32 txId) external {
        require(!processed[txId]);
        processed[txId] = true;
        IERC721(nft).transferFrom(address(this), user, tokenId);
        emit NFTBridgeReceived(user, tokenId);
    }
}
