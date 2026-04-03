// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Web3IdentitySBTSystem is ERC721 {
    struct Identity {
        string username;
        string avatarURI;
        uint256 level;
        bool verified;
    }

    mapping(address => Identity) public userIdentity;
    mapping(address => bool) public hasMinted;

    constructor() ERC721("Web3ID", "SBTID") {}

    function mintIdentity(string calldata username, string calldata avatar) external {
        require(!hasMinted[msg.sender]);
        _mint(msg.sender, uint256(uint160(msg.sender)));
        userIdentity[msg.sender] = Identity(username, avatar, 1, false);
        hasMinted[msg.sender] = true;
    }

    function verifyUser(address user) external {
        userIdentity[user].verified = true;
    }

    function transferFrom(address, address, uint256) public pure override {
        revert("SBT cannot transfer");
    }
}
