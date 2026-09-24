// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMessageBoard {

    struct Message {
        address sender;
        string text;
        uint256 timestamp;
    }

    mapping(address => Message) public messages;

    event MessageUpdated(
        address indexed sender,
        string text,
        uint256 timestamp
    );

    function setMessage(string calldata text) external {
        messages[msg.sender] = Message({
            sender: msg.sender,
            text: text,
            timestamp: block.timestamp
        });

        emit MessageUpdated(
            msg.sender,
            text,
            block.timestamp
        );
    }

    function getMessage(address user)
        external
        view
        returns (
            address sender,
            string memory text,
            uint256 timestamp
        )
    {
        Message memory m = messages[user];

        return (
            m.sender,
            m.text,
            m.timestamp
        );
    }
}
