// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StablecoinWithCollateral is ERC20 {
    mapping(address => uint256) public collateralDeposits;
    uint256 public collateralRatio = 150;

    constructor() ERC20("USD Stable", "USDS") {}

    function mint(uint256 amount) external payable {
        uint256 requiredCollateral = (amount * collateralRatio) / 100;
        require(msg.value >= requiredCollateral, "Insufficient collateral");
        collateralDeposits[msg.sender] += msg.value;
        _mint(msg.sender, amount);
    }

    function redeem(uint256 amount) external {
        _burn(msg.sender, amount);
        uint256 collateral = collateralDeposits[msg.sender];
        collateralDeposits[msg.sender] = 0;
        payable(msg.sender).transfer(collateral);
    }
}
