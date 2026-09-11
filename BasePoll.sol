// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BasePoll {
    struct Poll {
        string question;
        uint256 yesVotes;
        uint256 noVotes;
        bool active;
    }

    mapping(uint256 => Poll) public polls;
    mapping(uint256 => mapping(address => bool)) public voted;

    function createPoll(uint256 pollId, string calldata question) external {
        require(!polls[pollId].active, "Poll exists");

        polls[pollId] = Poll({
            question: question,
            yesVotes: 0,
            noVotes: 0,
            active: true
        });
    }

    function vote(uint256 pollId, bool yes) external {
        require(polls[pollId].active, "Poll not active");
        require(!voted[pollId][msg.sender], "Already voted");

        voted[pollId][msg.sender] = true;

        if (yes) {
            polls[pollId].yesVotes++;
        } else {
            polls[pollId].noVotes++;
        }
    }
}
