// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseQueue {

    struct QueueEntry {
        address user;
        uint256 joinedAt;
        bool processed;
    }

    QueueEntry[] public queue;

    mapping(address => bool) public inQueue;
    mapping(address => uint256) public position;

    uint256 public nextToProcess;

    event JoinedQueue(
        address indexed user,
        uint256 indexed position,
        uint256 timestamp
    );

    event Processed(
        address indexed user,
        uint256 indexed position,
        uint256 timestamp
    );

    function joinQueue() external {
        require(
            !inQueue[msg.sender],
            "Already in queue"
        );

        uint256 pos = queue.length;

        queue.push(
            QueueEntry({
                user: msg.sender,
                joinedAt: block.timestamp,
                processed: false
            })
        );

        inQueue[msg.sender] = true;
        position[msg.sender] = pos;

        emit JoinedQueue(
            msg.sender,
            pos,
            block.timestamp
        );
    }

    function processNext() external {
        require(
            nextToProcess < queue.length,
            "Queue is empty"
        );

        QueueEntry storage entry = queue[nextToProcess];

        require(
            !entry.processed,
            "Already processed"
        );

        entry.processed = true;
        inQueue[entry.user] = false;

        emit Processed(
            entry.user,
            nextToProcess,
            block.timestamp
        );

        nextToProcess++;
    }

    function getQueueLength()
        external
        view
        returns (uint256)
    {
        return queue.length - nextToProcess;
    }

    function getMyPosition()
        external
        view
        returns (uint256)
    {
        require(inQueue[msg.sender], "Not in queue");
        return position[msg.sender];
    }
}
