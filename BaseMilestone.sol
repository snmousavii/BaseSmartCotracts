// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMilestone {

    struct Milestone {
        string title;
        bool completed;
        uint256 createdAt;
        uint256 completedAt;
    }

    mapping(address => Milestone[]) public milestones;

    event MilestoneCreated(
        address indexed user,
        uint256 indexed milestoneId,
        string title
    );

    event MilestoneCompleted(
        address indexed user,
        uint256 indexed milestoneId,
        uint256 timestamp
    );

    function createMilestone(
        string calldata title
    ) external {
        require(bytes(title).length > 0, "Empty title");

        milestones[msg.sender].push(
            Milestone({
                title: title,
                completed: false,
                createdAt: block.timestamp,
                completedAt: 0
            })
        );

        emit MilestoneCreated(
            msg.sender,
            milestones[msg.sender].length - 1,
            title
        );
    }

    function completeMilestone(
        uint256 milestoneId
    ) external {
        require(
            milestoneId < milestones[msg.sender].length,
            "Invalid milestone"
        );

        require(
            !milestones[msg.sender][milestoneId].completed,
            "Already completed"
        );

        milestones[msg.sender][milestoneId].completed = true;
        milestones[msg.sender][milestoneId].completedAt = block.timestamp;

        emit MilestoneCompleted(
            msg.sender,
            milestoneId,
            block.timestamp
        );
    }

    function getMilestoneCount(
        address user
    ) external view returns (uint256) {
        return milestones[user].length;
    }

    function getMilestone(
        address user,
        uint256 milestoneId
    )
        external
        view
        returns (
            string memory title,
            bool completed,
            uint256 createdAt,
            uint256 completedAt
        )
    {
        require(
            milestoneId < milestones[user].length,
            "Invalid milestone"
        );

        Milestone memory m = milestones[user][milestoneId];

        return (
            m.title,
            m.completed,
            m.createdAt,
            m.completedAt
        );
    }
}
