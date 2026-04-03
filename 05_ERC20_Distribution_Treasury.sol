// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20DistributionTreasury is Ownable {
    IERC20 public immutable rewardToken;
    uint256 public distributionInterval = 1 days;
    mapping(address => uint256) public lastClaimTime;

    event Distributed(address indexed user, uint256 amount);

    constructor(address _token) {
        rewardToken = IERC20(_token);
    }

    function distribute(address[] calldata users, uint256 amountPerUser) external onlyOwner {
        for (uint i = 0; i < users.length; i++) {
            rewardToken.transfer(users[i], amountPerUser);
            emit Distributed(users[i], amountPerUser);
        }
    }

    function claim() external {
        require(block.timestamp >= lastClaimTime[msg.sender] + distributionInterval, "Too soon");
        lastClaimTime[msg.sender] = block.timestamp;
        rewardToken.transfer(msg.sender, 100 * 1e18);
        emit Distributed(msg.sender, 100 * 1e18);
    }

    function withdrawFunds(uint256 amount) external onlyOwner {
        rewardToken.transfer(msg.sender, amount);
    }
}
