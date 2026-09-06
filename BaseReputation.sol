// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseReputation {
    mapping(address => uint256) public reputation;
    mapping(address => uint256) public activities;

    uint256 public totalActivities;

    function addReputation(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        reputation[msg.sender] += amount;
        activities[msg.sender]++;
        totalActivities++;
    }

    function getReputation(address user) external view returns (uint256) {
        return reputation[user];
    }

    function getActivities(address user) external view returns (uint256) {
        return activities[user];
    }
}
