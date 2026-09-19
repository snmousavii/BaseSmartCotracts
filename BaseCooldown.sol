// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCooldown {
    mapping(address => uint256) public nextAllowedTime;

    uint256 public constant COOLDOWN = 1 hours;

    function trigger() external {
        require(
            block.timestamp >= nextAllowedTime[msg.sender],
            "Cooldown active"
        );

        nextAllowedTime[msg.sender] = block.timestamp + COOLDOWN;
    }

    function remaining(address user)
        external
        view
        returns (uint256)
    {
        if (block.timestamp >= nextAllowedTime[user]) {
            return 0;
        }

        return nextAllowedTime[user] - block.timestamp;
    }
}
