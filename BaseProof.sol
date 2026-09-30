// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseProof {

    struct Proof {
        address owner;
        uint256 timestamp;
        bool exists;
    }

    mapping(bytes32 => Proof) public proofs;

    uint256 public totalProofs;

    event ProofRegistered(
        bytes32 indexed dataHash,
        address indexed owner,
        uint256 timestamp
    );

    function registerProof(bytes32 dataHash) external {
        require(
            dataHash != bytes32(0),
            "Invalid hash"
        );

        require(
            !proofs[dataHash].exists,
            "Proof already exists"
        );

        proofs[dataHash] = Proof({
            owner: msg.sender,
            timestamp: block.timestamp,
            exists: true
        });

        totalProofs++;

        emit ProofRegistered(
            dataHash,
            msg.sender,
            block.timestamp
        );
    }

    function verifyProof(bytes32 dataHash)
        external
        view
        returns (
            address owner,
            uint256 timestamp,
            bool exists
        )
    {
        Proof memory proof = proofs[dataHash];

        return (
            proof.owner,
            proof.timestamp,
            proof.exists
        );
    }
}
