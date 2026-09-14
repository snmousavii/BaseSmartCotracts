// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseQueue {
    mapping(uint256 => uint256) private queue;

    uint256 public first;
    uint256 public last;

    function enqueue(uint256 value) external {
        queue[last] = value;
        last++;
    }

    function dequeue() external returns (uint256) {
        require(first < last, "Queue is empty");

        uint256 value = queue[first];
        delete queue[first];
        first++;

        return value;
    }

    function peek() external view returns (uint256) {
        require(first < last, "Queue is empty");
        return queue[first];
    }

    function size() external view returns (uint256) {
        return last - first;
    }
}
