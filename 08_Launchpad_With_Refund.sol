// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LaunchpadWithRefund {
    IERC20 public token;
    uint256 public price;
    uint256 public hardCap;
    uint256 public raised;
    uint256 public endTime;
    bool public finalized;
    mapping(address => uint256) public contributions;

    event Invested(address indexed user, uint256 amount);
    event Claimed(address indexed user, uint256 tokens);
    event Refunded(address indexed user, uint256 amount);

    constructor(address _token, uint256 _price, uint256 _hardCap, uint256 _duration) {
        token = IERC20(_token);
        price = _price;
        hardCap = _hardCap;
        endTime = block.timestamp + _duration;
    }

    function invest() external payable {
        require(block.timestamp < endTime && raised < hardCap);
        contributions[msg.sender] += msg.value;
        raised += msg.value;
        emit Invested(msg.sender, msg.value);
    }

    function claimTokens() external {
        require(finalized);
        uint256 amount = contributions[msg.sender] * price;
        contributions[msg.sender] = 0;
        token.transfer(msg.sender, amount);
        emit Claimed(msg.sender, amount);
    }

    function refund() external {
        require(block.timestamp > endTime && raised < hardCap);
        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit Refunded(msg.sender, amount);
    }

    function finalize() external {
        require(block.timestamp > endTime || raised >= hardCap);
        finalized = true;
    }
}
