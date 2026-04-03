// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AdvancedDefiYieldOptimizer is Ownable {
    IERC20 public immutable stakeToken;
    IERC20 public immutable rewardToken;
    uint256 public rewardPerSecond;
    uint256 public lastRewardTime;
    uint256 public rewardPerTokenStored;
    uint256 public totalStaked;

    mapping(address => uint256) public userStakedAmount;
    mapping(address => uint256) public userRewardDebt;
    mapping(address => uint256) public userUnclaimedRewards;

    event Staked(address indexed user, uint256 amount);
    event Unstaked(address indexed user, uint256 amount);
    event RewardClaimed(address indexed user, uint256 reward);

    constructor(address _stakeToken, address _rewardToken, uint256 _rewardPerSecond) {
        stakeToken = IERC20(_stakeToken);
        rewardToken = IERC20(_rewardToken);
        rewardPerSecond = _rewardPerSecond;
        lastRewardTime = block.timestamp;
    }

    modifier updateReward() {
        rewardPerTokenStored = rewardPerToken();
        lastRewardTime = block.timestamp;
        _;
    }

    function rewardPerToken() public view returns (uint256) {
        if (totalStaked == 0) {
            return rewardPerTokenStored;
        }
        return rewardPerTokenStored + ((block.timestamp - lastRewardTime) * rewardPerSecond * 1e18) / totalStaked;
    }

    function earned(address account) public view returns (uint256) {
        return (userStakedAmount[account] * (rewardPerToken() - userRewardDebt[account])) / 1e18 + userUnclaimedRewards[account];
    }

    function stake(uint256 amount) external updateReward {
        require(amount > 0, "Cannot stake 0");
        totalStaked += amount;
        userStakedAmount[msg.sender] += amount;
        userRewardDebt[msg.sender] = rewardPerTokenStored;
        stakeToken.transferFrom(msg.sender, address(this), amount);
        emit Staked(msg.sender, amount);
    }

    function unstake(uint256 amount) external updateReward {
        require(amount > 0, "Cannot unstake 0");
        require(userStakedAmount[msg.sender] >= amount, "Insufficient balance");
        totalStaked -= amount;
        userStakedAmount[msg.sender] -= amount;
        userRewardDebt[msg.sender] = rewardPerTokenStored;
        stakeToken.transfer(msg.sender, amount);
        emit Unstaked(msg.sender, amount);
    }

    function claim() external updateReward {
        uint256 reward = earned(msg.sender);
        require(reward > 0, "No reward to claim");
        userUnclaimedRewards[msg.sender] = 0;
        rewardToken.transfer(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }

    function setRewardPerSecond(uint256 _rewardPerSecond) external onlyOwner {
        rewardPerSecond = _rewardPerSecond;
    }
}
