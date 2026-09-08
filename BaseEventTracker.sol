// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseEventTracker {
    mapping(address => uint256) public actions;
    uint256 public totalActions;

    event ActionRecorded(address indexed user, uint256 actionNumber);

    function recordAction() external {
        actions[msg.sender]++;
        totalActions++;

        emit ActionRecorded(
            msg.sender,
            actions[msg.sender]
        );
    }

    function getActions(address user)
        external
        view
        returns (uint256)
    {
        return actions[user];
    }
}
