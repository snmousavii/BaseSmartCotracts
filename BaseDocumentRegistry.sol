// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDocumentRegistry {
    struct Document {
        bytes32 hash;
        uint256 timestamp;
    }

    mapping(uint256 => Document) public documents;

    function registerDocument(uint256 id, bytes32 hash) external {
        require(documents[id].timestamp == 0, "Already registered");

        documents[id] = Document({
            hash: hash,
            timestamp: block.timestamp
        });
    }

    function verifyDocument(uint256 id, bytes32 hash) external view returns (bool) {
        return documents[id].hash == hash;
    }
}
