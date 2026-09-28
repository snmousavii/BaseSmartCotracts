// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseLink {

    struct Link {
        string url;
        string title;
        uint256 createdAt;
    }

    mapping(address => Link) public links;

    event LinkSaved(
        address indexed user,
        string url,
        string title
    );

    function saveLink(
        string calldata url,
        string calldata title
    ) external {
        require(bytes(url).length > 0, "Empty URL");

        links[msg.sender] = Link({
            url: url,
            title: title,
            createdAt: block.timestamp
        });

        emit LinkSaved(
            msg.sender,
            url,
            title
        );
    }

    function getLink(address user)
        external
        view
        returns (
            string memory url,
            string memory title,
            uint256 createdAt
        )
    {
        Link memory link = links[user];

        return (
            link.url,
            link.title,
            link.createdAt
        );
    }
}
