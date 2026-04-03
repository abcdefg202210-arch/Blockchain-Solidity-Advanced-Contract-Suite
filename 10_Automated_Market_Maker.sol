// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract AutomatedMarketMaker {
    IERC20 public tokenA;
    IERC20 public tokenB;
    uint256 public reserveA;
    uint256 public reserveB;
    uint256 public fee = 3;

    event Swapped(address indexed user, address inToken, uint256 inAmt, uint256 outAmt);

    constructor(address _a, address _b) {
        tokenA = IERC20(_a);
        tokenB = IERC20(_b);
    }

    function addLiquidity(uint256 a, uint256 b) external {
        tokenA.transferFrom(msg.sender, address(this), a);
        tokenB.transferFrom(msg.sender, address(this), b);
        reserveA += a;
        reserveB += b;
    }

    function swap(address inToken, uint256 amount) external returns (uint256) {
        uint256 outAmount;
        if (inToken == address(tokenA)) {
            tokenA.transferFrom(msg.sender, address(this), amount);
            reserveA += amount;
            outAmount = (reserveB * amount) / reserveA;
            reserveB -= outAmount;
            tokenB.transfer(msg.sender, outAmount);
        } else {
            tokenB.transferFrom(msg.sender, address(this), amount);
            reserveB += amount;
            outAmount = (reserveA * amount) / reserveB;
            reserveA -= outAmount;
            tokenA.transfer(msg.sender, outAmount);
        }
        emit Swapped(msg.sender, inToken, amount, outAmount);
        return outAmount;
    }
}
