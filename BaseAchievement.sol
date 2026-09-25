// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseAchievement {

    struct Achievement {
        string title;
        uint256 createdAt;
        uint256 updatedAt;
    }

    mapping(address => Achievement) public achievements;

    event AchievementCreated(
        address indexed user,
        string title
    );

    event AchievementUpdated(
        address indexed user,
        string title
    );

    function createAchievement(string calldata title) external {
        require(bytes(title).length > 0, "Empty title");
        require(
            bytes(achievements[msg.sender].title).length == 0,
            "Already exists"
        );

        achievements[msg.sender] = Achievement({
            title: title,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        emit AchievementCreated(msg.sender, title);
    }

    function updateAchievement(string calldata title) external {
        require(
            bytes(achievements[msg.sender].title).length > 0,
            "Not created"
        );
        require(bytes(title).length > 0, "Empty title");

        achievements[msg.sender].title = title;
        achievements[msg.sender].updatedAt = block.timestamp;

        emit AchievementUpdated(msg.sender, title);
    }
}
