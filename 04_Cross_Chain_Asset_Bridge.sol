// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CrossChainAssetBridge {
    address public validator;
    uint256 public chainId;
    mapping(bytes32 => bool) public processedTransactions;

    event BridgeInitiated(address indexed user, uint256 destChain, uint256 amount, bytes32 txId);
    event BridgeCompleted(address indexed user, uint256 amount);

    constructor(uint256 _chainId) {
        validator = msg.sender;
        chainId = _chainId;
    }

    function initiateBridge(address token, uint256 destChain, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        bytes32 txId = keccak256(abi.encodePacked(msg.sender, chainId, destChain, amount, block.timestamp));
        emit BridgeInitiated(msg.sender, destChain, amount, txId);
    }

    function completeBridge(address user, uint256 amount, bytes32 txId, bytes calldata signature) external {
        require(!processedTransactions[txId], "Tx processed");
        processedTransactions[txId] = true;
        (bool success,) = user.call{value: amount}("");
        require(success, "Transfer failed");
        emit BridgeCompleted(user, amount);
    }
}
