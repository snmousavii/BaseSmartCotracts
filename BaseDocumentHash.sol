// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDocumentHash {
    struct Document {
        bytes32 hash;
        uint256 timestamp;
    }

    mapping(uint256 => Document) public documents;

    function registerDocument(uint256 documentId, bytes32 documentHash) external {
        documents[documentId] = Document(documentHash, block.timestamp);
    }

    function getDocument(uint256 documentId)
        external
        view
        returns (bytes32 hash, uint256 timestamp)
    {
        Document memory doc = documents[documentId];
        return (doc.hash, doc.timestamp);
    }
}
