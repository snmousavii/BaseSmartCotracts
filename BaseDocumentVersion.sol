// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDocumentVersion {
    struct Version {
        bytes32 hash;
        uint256 createdAt;
    }

    mapping(uint256 => Version[]) private versions;

    function addVersion(uint256 documentId, bytes32 documentHash) external {
        versions[documentId].push(
            Version(documentHash, block.timestamp)
        );
    }

    function getVersion(
        uint256 documentId,
        uint256 versionIndex
    ) external view returns (bytes32 hash, uint256 createdAt) {
        Version memory version = versions[documentId][versionIndex];
        return (version.hash, version.createdAt);
    }

    function getVersionCount(uint256 documentId)
        external
        view
        returns (uint256)
    {
        return versions[documentId].length;
    }
}
