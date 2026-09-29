// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseBookmark {

    mapping(address => mapping(uint256 => bool)) public bookmarked;
    mapping(address => uint256) public bookmarkCount;

    event BookmarkAdded(
        address indexed user,
        uint256 indexed itemId
    );

    event BookmarkRemoved(
        address indexed user,
        uint256 indexed itemId
    );

    function addBookmark(uint256 itemId) external {
        require(!bookmarked[msg.sender][itemId], "Already bookmarked");

        bookmarked[msg.sender][itemId] = true;
        bookmarkCount[msg.sender]++;

        emit BookmarkAdded(msg.sender, itemId);
    }

    function removeBookmark(uint256 itemId) external {
        require(bookmarked[msg.sender][itemId], "Not bookmarked");

        bookmarked[msg.sender][itemId] = false;
        bookmarkCount[msg.sender]--;

        emit BookmarkRemoved(msg.sender, itemId);
    }

    function isBookmarked(
        address user,
        uint256 itemId
    ) external view returns (bool) {
        return bookmarked[user][itemId];
    }

    function getBookmarkCount(
        address user
    ) external view returns (uint256) {
        return bookmarkCount[user];
    }
}
