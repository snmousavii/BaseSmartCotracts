// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseVoting {
    uint256 public yesVotes;
    uint256 public noVotes;

    mapping(address => bool) public hasVoted;

    function voteYes() external {
        require(!hasVoted[msg.sender], "Already voted");
        hasVoted[msg.sender] = true;
        yesVotes++;
    }

    function voteNo() external {
        require(!hasVoted[msg.sender], "Already voted");
        hasVoted[msg.sender] = true;
        noVotes++;
    }

    function totalVotes() external view returns (uint256) {
        return yesVotes + noVotes;
    }
}
}
