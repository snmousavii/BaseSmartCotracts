// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseNumberRegistry {
    mapping(address => uint256) public number;
    mapping(address => bool) public hasNumber;

    uint256 public totalUsers;

    function setNumber(uint256 value) external {
        if (!hasNumber[msg.sender]) {
            hasNumber[msg.sender] = true;
            totalUsers++;
        }

        number[msg.sender] = value;
    }

    function getNumber(address user) external view returns (uint256) {
        return number[user];
    }
}
