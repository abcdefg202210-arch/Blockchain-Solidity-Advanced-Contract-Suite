// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PriceOracleWithTWAP {
    uint256 public price;
    uint256 public lastUpdate;
    uint256 public cumulativePrice;
    uint256 public updateCount;

    event PriceUpdated(uint256 newPrice, uint256 timestamp);

    function updatePrice(uint256 newPrice) external {
        price = newPrice;
        cumulativePrice += newPrice;
        updateCount++;
        lastUpdate = block.timestamp;
        emit PriceUpdated(newPrice, block.timestamp);
    }

    function getTWAP() external view returns (uint256) {
        return updateCount == 0 ? 0 : cumulativePrice / updateCount;
    }
}
