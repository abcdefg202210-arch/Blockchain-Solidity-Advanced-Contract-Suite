// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DefiLiquidityMining {
    IERC20 public lpToken;
    IERC20 public rewardToken;
    uint256 public rewardRate;
    uint256 public lastTime;
    uint256 public rewardPerToken;
    uint256 public totalLP;

    mapping(address => uint256) public balance;
    mapping(address => uint256) public debt;

    constructor(address _lp, address _reward, uint256 _rate) {
        lpToken = IERC20(_lp);
        rewardToken = IERC20(_reward);
        rewardRate = _rate;
        lastTime = block.timestamp;
    }

    function update() internal {
        rewardPerToken += ((block.timestamp - lastTime) * rewardRate * 1e18) / totalLP;
        lastTime = block.timestamp;
    }

    function deposit(uint256 amount) external {
        update();
        lpToken.transferFrom(msg.sender, address(this), amount);
        balance[msg.sender] += amount;
        debt[msg.sender] = balance[msg.sender] * rewardPerToken;
        totalLP += amount;
    }

    function claim() external {
        update();
        uint256 reward = (balance[msg.sender] * rewardPerToken - debt[msg.sender]) / 1e18;
        rewardToken.transfer(msg.sender, reward);
        debt[msg.sender] = balance[msg.sender] * rewardPerToken;
    }
}
