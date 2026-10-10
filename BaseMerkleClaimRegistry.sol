// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMerkleClaimRegistry {

    struct Campaign {
        bytes32 merkleRoot;
        uint256 createdAt;
        bool exists;
    }

    mapping(address => mapping(uint256 => Campaign))
        public campaigns;

    mapping(address => mapping(uint256 => mapping(address => bool)))
        public claimed;

    event CampaignPublished(
        address indexed publisher,
        uint256 indexed campaignId,
        bytes32 merkleRoot
    );

    event ClaimRecorded(
        address indexed publisher,
        uint256 indexed campaignId,
        address indexed user,
        uint256 allocation
    );

    function publishCampaign(
        uint256 campaignId,
        bytes32 merkleRoot
    ) external {
        require(merkleRoot != bytes32(0), "Invalid root");

        require(
            !campaigns[msg.sender][campaignId].exists,
            "Campaign already exists"
        );

        campaigns[msg.sender][campaignId] = Campaign({
            merkleRoot: merkleRoot,
            createdAt: block.timestamp,
            exists: true
        });

        emit CampaignPublished(
            msg.sender,
            campaignId,
            merkleRoot
        );
    }

    function claim(
        address publisher,
        uint256 campaignId,
        uint256 allocation,
        bytes32[] calldata proof
    ) external {
        Campaign storage campaign =
            campaigns[publisher][campaignId];

        require(campaign.exists, "Campaign not found");

        require(
            !claimed[publisher][campaignId][msg.sender],
            "Already claimed"
        );

        bytes32 leaf = keccak256(
            bytes.concat(
                keccak256(abi.encode(msg.sender, allocation))
            )
        );

        require(
            _verify(campaign.merkleRoot, leaf, proof),
            "Invalid proof"
        );

        claimed[publisher][campaignId][msg.sender] = true;

        emit ClaimRecorded(
            publisher,
            campaignId,
            msg.sender,
            allocation
        );
    }

    function verifyProof(
        address publisher,
        uint256 campaignId,
        address account,
        uint256 allocation,
        bytes32[] calldata proof
    ) external view returns (bool) {
        Campaign storage campaign =
            campaigns[publisher][campaignId];

        if (!campaign.exists || account == address(0)) {
            return false;
        }

        bytes32 leaf = keccak256(
            bytes.concat(
                keccak256(abi.encode(account, allocation))
            )
        );

        return _verify(campaign.merkleRoot, leaf, proof);
    }

    function _verify(
        bytes32 root,
        bytes32 leaf,
        bytes32[] calldata proof
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (uint256(computedHash) <= uint256(proofElement)) {
                computedHash = keccak256(
                    abi.encodePacked(computedHash, proofElement)
                );
            } else {
                computedHash = keccak256(
                    abi.encodePacked(proofElement, computedHash)
                );
            }
        }

        return computedHash == root;
    }

    function isClaimed(
        address publisher,
        uint256 campaignId,
        address user
    ) external view returns (bool) {
        return claimed[publisher][campaignId][user];
    }
}
