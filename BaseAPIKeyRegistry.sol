// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseAPIKeyRegistry {

    struct APIKey {
        bytes32 keyHash;
        string label;
        uint256 createdAt;
        uint256 updatedAt;
        bool active;
    }

    mapping(address => mapping(uint256 => APIKey))
        private apiKeys;

    mapping(address => mapping(bytes32 => bool))
        private hashInUse;

    mapping(address => uint256) public keyCount;

    event APIKeyAdded(
        address indexed user,
        uint256 indexed keyId,
        bytes32 keyHash,
        string label
    );

    event APIKeyRotated(
        address indexed user,
        uint256 indexed keyId,
        bytes32 newKeyHash
    );

    event APIKeyRevoked(
        address indexed user,
        uint256 indexed keyId
    );

    function addKey(
        bytes32 keyHash,
        string calldata label
    ) external {
        require(keyHash != bytes32(0), "Invalid hash");
        require(bytes(label).length > 0, "Empty label");
        require(!hashInUse[msg.sender][keyHash], "Hash already in use");

        uint256 id = keyCount[msg.sender];

        apiKeys[msg.sender][id] = APIKey({
            keyHash: keyHash,
            label: label,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            active: true
        });

        hashInUse[msg.sender][keyHash] = true;
        keyCount[msg.sender]++;

        emit APIKeyAdded(msg.sender, id, keyHash, label);
    }

    function rotateKey(
        uint256 keyId,
        bytes32 newKeyHash
    ) external {
        require(keyId < keyCount[msg.sender], "Invalid key ID");
        require(newKeyHash != bytes32(0), "Invalid hash");

        APIKey storage key = apiKeys[msg.sender][keyId];

        require(key.active, "Key is inactive");
        require(
            newKeyHash != key.keyHash,
            "Same hash"
        );
        require(
            !hashInUse[msg.sender][newKeyHash],
            "Hash already in use"
        );

        hashInUse[msg.sender][key.keyHash] = false;
        hashInUse[msg.sender][newKeyHash] = true;

        key.keyHash = newKeyHash;
        key.updatedAt = block.timestamp;

        emit APIKeyRotated(msg.sender, keyId, newKeyHash);
    }

    function revokeKey(uint256 keyId) external {
        require(keyId < keyCount[msg.sender], "Invalid key ID");

        APIKey storage key = apiKeys[msg.sender][keyId];

        require(key.active, "Already revoked");

        hashInUse[msg.sender][key.keyHash] = false;
        key.active = false;
        key.updatedAt = block.timestamp;

        emit APIKeyRevoked(msg.sender, keyId);
    }

    function getKey(
        address user,
        uint256 keyId
    )
        external
        view
        returns (
            bytes32 keyHash,
            string memory label,
            uint256 createdAt,
            uint256 updatedAt,
            bool active
        )
    {
        require(keyId < keyCount[user], "Invalid key ID");

        APIKey memory key = apiKeys[user][keyId];

        return (
            key.keyHash,
            key.label,
            key.createdAt,
            key.updatedAt,
            key.active
        );
    }
}
