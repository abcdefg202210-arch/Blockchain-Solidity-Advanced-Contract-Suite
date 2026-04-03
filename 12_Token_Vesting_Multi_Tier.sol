// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenVestingMultiTier {
    IERC20 public token;
    struct Vesting {
        uint256 total;
        uint256 claimed;
        uint256 startTime;
        uint256 duration;
    }
    mapping(address => Vesting[]) public userVestings;

    event VestingCreated(address indexed user, uint256 amount, uint256 duration);
    event Claimed(address indexed user, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
    }

    function createVesting(address user, uint256 amount, uint256 duration) external {
        userVestings[user].push(Vesting(amount, 0, block.timestamp, duration));
        emit VestingCreated(user, amount, duration);
    }

    function claim() external {
        uint256 totalClaim;
        for (uint i = 0; i < userVestings[msg.sender].length; i++) {
            Vesting storage v = userVestings[msg.sender][i];
            uint256 elapsed = block.timestamp - v.startTime;
            uint256 available = (v.total * elapsed) / v.duration - v.claimed;
            if (available > 0) {
                v.claimed += available;
                totalClaim += available;
            }
        }
        token.transfer(msg.sender, totalClaim);
        emit Claimed(msg.sender, totalClaim);
    }
}
