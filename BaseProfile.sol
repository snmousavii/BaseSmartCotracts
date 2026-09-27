// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseProfile {

    struct Profile {
        string name;
        string bio;
        uint256 updatedAt;
    }

    mapping(address => Profile) public profiles;

    event ProfileUpdated(
        address indexed user,
        string name,
        string bio
    );

    function setProfile(
        string calldata name,
        string calldata bio
    ) external {
        profiles[msg.sender] = Profile({
            name: name,
            bio: bio,
            updatedAt: block.timestamp
        });

        emit ProfileUpdated(
            msg.sender,
            name,
            bio
        );
    }

    function getProfile(address user)
        external
        view
        returns (
            string memory name,
            string memory bio,
            uint256 updatedAt
        )
    {
        Profile memory p = profiles[user];

        return (
            p.name,
            p.bio,
            p.updatedAt
        );
    }
}
