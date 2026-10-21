// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseIPLicenseManager {

    struct Work {
        address creator;
        string title;
        bytes32 contentHash;
        bytes32 termsHash;
        bool exists;
    }

    struct License {
        uint256 expiresAt; // 0 means no expiry
        bool active;
    }

    mapping(uint256 => Work) private works;

    mapping(uint256 => mapping(address => License))
        public licenses;

    uint256 public workCount;

    event WorkRegistered(
        uint256 indexed workId,
        address indexed creator,
        bytes32 contentHash
    );

    event LicenseGranted(
        uint256 indexed workId,
        address indexed licensee,
        uint256 expiresAt
    );

    event LicenseRevoked(
        uint256 indexed workId,
        address indexed licensee
    );

    event TermsUpdated(
        uint256 indexed workId,
        bytes32 newTermsHash
    );

    function registerWork(
        string calldata title,
        bytes32 contentHash,
        bytes32 termsHash
    ) external returns (uint256) {
        require(bytes(title).length > 0, "Empty title");
        require(contentHash != bytes32(0), "Invalid content hash");
        require(termsHash != bytes32(0), "Invalid terms hash");

        uint256 id = workCount;

        works[id] = Work({
            creator: msg.sender,
            title: title,
            contentHash: contentHash,
            termsHash: termsHash,
            exists: true
        });

        workCount++;

        emit WorkRegistered(id, msg.sender, contentHash);

        return id;
    }

    function grantLicense(
        uint256 workId,
        address licensee,
        uint256 expiresAt
    ) external {
        require(workId < workCount, "Invalid work");
        require(licensee != address(0), "Invalid licensee");
        require(licensee != works[workId].creator, "Creator is not licensee");
        require(works[workId].creator == msg.sender, "Not creator");

        require(
            expiresAt == 0 || expiresAt > block.timestamp,
            "Invalid expiry"
        );

        licenses[workId][licensee] = License({
            expiresAt: expiresAt,
            active: true
        });

        emit LicenseGranted(workId, licensee, expiresAt);
    }

    function revokeLicense(
        uint256 workId,
        address licensee
    ) external {
        require(workId < workCount, "Invalid work");
        require(works[workId].creator == msg.sender, "Not creator");
        require(licenses[workId][licensee].active, "Not active");

        licenses[workId][licensee].active = false;

        emit LicenseRevoked(workId, licensee);
    }

    function updateTerms(
        uint256 workId,
        bytes32 newTermsHash
    ) external {
        require(workId < workCount, "Invalid work");
        require(works[workId].creator == msg.sender, "Not creator");
        require(newTermsHash != bytes32(0), "Invalid hash");

        works[workId].termsHash = newTermsHash;

        emit TermsUpdated(workId, newTermsHash);
    }

    function isLicenseActive(
        uint256 workId,
        address licensee
    ) external view returns (bool) {
        if (workId >= workCount) {
            return false;
        }

        License memory lic = licenses[workId][licensee];

        return lic.active &&
            (lic.expiresAt == 0 || block.timestamp < lic.expiresAt);
    }

    function getWork(
        uint256 workId
    )
        external
        view
        returns (
            address creator,
            string memory title,
            bytes32 contentHash,
            bytes32 termsHash
        )
    {
        require(workId < workCount, "Invalid work");

        Work memory work = works[workId];

        return (
            work.creator,
            work.title,
            work.contentHash,
            work.termsHash
        );
    }
}
