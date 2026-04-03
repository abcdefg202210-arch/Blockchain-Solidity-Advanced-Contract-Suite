// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract NFTStakingRewardSystem {
    IERC721 public nftContract;
    IERC20 public rewardToken;
    uint256 public rewardPerDay;

    struct StakeInfo {
        uint256 tokenId;
        uint256 startTime;
        uint256 claimedRewards;
    }

    mapping(address => StakeInfo[]) public userStakes;
    mapping(uint256 => address) public tokenOwner;

    event NFTStaked(address indexed user, uint256 tokenId);
    event NFTUnstaked(address indexed user, uint256 tokenId);
    event RewardClaimed(address indexed user, uint256 amount);

    constructor(address _nft, address _reward, uint256 _rewardPerDay) {
        nftContract = IERC721(_nft);
        rewardToken = IERC20(_reward);
        rewardPerDay = _rewardPerDay;
    }

    function stakeNFT(uint256 tokenId) external {
        nftContract.transferFrom(msg.sender, address(this), tokenId);
        userStakes[msg.sender].push(StakeInfo(tokenId, block.timestamp, 0));
        tokenOwner[tokenId] = msg.sender;
        emit NFTStaked(msg.sender, tokenId);
    }

    function calculateReward(address user) public view returns (uint256) {
        uint256 total;
        StakeInfo[] memory stakes = userStakes[user];
        for (uint i = 0; i < stakes.length; i++) {
            uint256 daysStaked = (block.timestamp - stakes[i].startTime) / 1 days;
            total += daysStaked * rewardPerDay - stakes[i].claimedRewards;
        }
        return total;
    }

    function claimRewards() external {
        uint256 reward = calculateReward(msg.sender);
        require(reward > 0);
        rewardToken.transfer(msg.sender, reward);
        emit RewardClaimed(msg.sender, reward);
    }

    function unstakeNFT(uint256 tokenId) external {
        require(tokenOwner[tokenId] == msg.sender);
        nftContract.transferFrom(address(this), msg.sender, tokenId);
        tokenOwner[tokenId] = address(0);
        emit NFTUnstaked(msg.sender, tokenId);
    }
}
