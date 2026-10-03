// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDocumentHash {

    struct Document {
        bytes32 dataHash;
        string label;
        uint256 timestamp;
        bool active;
    }

    mapping(address => Document[]) public documents;

    event DocumentAdded(
        address indexed user,
        uint256 indexed documentId,
        bytes32 dataHash,
        string label
    );

    event DocumentDeactivated(
        address indexed user,
        uint256 indexed documentId
    );

    function addDocument(
        bytes32 dataHash,
        string calldata label
    ) external {
        require(dataHash != bytes32(0), "Invalid hash");
        require(bytes(label).length > 0, "Empty label");

        documents[msg.sender].push(
            Document({
                dataHash: dataHash,
                label: label,
                timestamp: block.timestamp,
                active: true
            })
        );

        emit DocumentAdded(
            msg.sender,
            documents[msg.sender].length - 1,
            dataHash,
            label
        );
    }

    function deactivateDocument(
        uint256 documentId
    ) external {
        require(
            documentId < documents[msg.sender].length,
            "Invalid document"
        );

        require(
            documents[msg.sender][documentId].active,
            "Already inactive"
        );

        documents[msg.sender][documentId].active = false;

        emit DocumentDeactivated(
            msg.sender,
            documentId
        );
    }

    function getDocumentCount(
        address user
    ) external view returns (uint256) {
        return documents[user].length;
    }

    function verifyDocument(
        address user,
        uint256 documentId,
        bytes32 dataHash
    ) external view returns (bool) {
        require(
            documentId < documents[user].length,
            "Invalid document"
        );

        return (
            documents[user][documentId].dataHash == dataHash &&
            documents[user][documentId].active
        );
    }
}
