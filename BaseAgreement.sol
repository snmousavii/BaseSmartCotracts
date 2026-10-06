// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseAgreement {

    enum Status {
        Proposed,
        Accepted,
        Rejected,
        Cancelled
    }

    struct Agreement {
        uint256 id;
        address proposer;
        address counterparty;
        string title;
        bytes32 termsHash;
        uint256 createdAt;
        Status status;
    }

    Agreement[] public agreements;

    event AgreementCreated(
        uint256 indexed id,
        address indexed proposer,
        address indexed counterparty,
        string title,
        bytes32 termsHash
    );

    event AgreementAccepted(
        uint256 indexed id,
        address indexed counterparty
    );

    event AgreementRejected(
        uint256 indexed id,
        address indexed counterparty
    );

    event AgreementCancelled(
        uint256 indexed id,
        address indexed proposer
    );

    function createAgreement(
        address counterparty,
        string calldata title,
        bytes32 termsHash
    ) external {
        require(counterparty != address(0), "Invalid counterparty");
        require(counterparty != msg.sender, "Invalid counterparty");
        require(bytes(title).length > 0, "Empty title");
        require(termsHash != bytes32(0), "Invalid terms hash");

        uint256 id = agreements.length;

        agreements.push(
            Agreement({
                id: id,
                proposer: msg.sender,
                counterparty: counterparty,
                title: title,
                termsHash: termsHash,
                createdAt: block.timestamp,
                status: Status.Proposed
            })
        );

        emit AgreementCreated(
            id,
            msg.sender,
            counterparty,
            title,
            termsHash
        );
    }

    function acceptAgreement(uint256 id) external {
        require(id < agreements.length, "Invalid agreement");

        Agreement storage agreement = agreements[id];

        require(
            msg.sender == agreement.counterparty,
            "Not counterparty"
        );

        require(
            agreement.status == Status.Proposed,
            "Not proposed"
        );

        agreement.status = Status.Accepted;

        emit AgreementAccepted(id, msg.sender);
    }

    function rejectAgreement(uint256 id) external {
        require(id < agreements.length, "Invalid agreement");

        Agreement storage agreement = agreements[id];

        require(
            msg.sender == agreement.counterparty,
            "Not counterparty"
        );

        require(
            agreement.status == Status.Proposed,
            "Not proposed"
        );

        agreement.status = Status.Rejected;

        emit AgreementRejected(id, msg.sender);
    }

    function cancelAgreement(uint256 id) external {
        require(id < agreements.length, "Invalid agreement");

        Agreement storage agreement = agreements[id];

        require(
            msg.sender == agreement.proposer,
            "Not proposer"
        );

        require(
            agreement.status == Status.Proposed,
            "Cannot cancel"
        );

        agreement.status = Status.Cancelled;

        emit AgreementCancelled(id, msg.sender);
    }

    function getAgreement(
        uint256 id
    )
        external
        view
        returns (
            uint256 agreementId,
            address proposer,
            address counterparty,
            string memory title,
            bytes32 termsHash,
            uint256 createdAt,
            Status status
        )
    {
        require(id < agreements.length, "Invalid agreement");

        Agreement memory agreement = agreements[id];

        return (
            agreement.id,
            agreement.proposer,
            agreement.counterparty,
            agreement.title,
            agreement.termsHash,
            agreement.createdAt,
            agreement.status
        );
    }

    function totalAgreements()
        external
        view
        returns (uint256)
    {
        return agreements.length;
    }
}
