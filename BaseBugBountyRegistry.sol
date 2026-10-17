// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseBugBountyRegistry {

    enum ReportStatus {
        Submitted,
        Triaged,
        Accepted,
        Rejected,
        Resolved
    }

    struct Program {
        address owner;
        string title;
        bytes32 scopeHash;
        uint256 createdAt;
        bool active;
    }

    struct Report {
        address reporter;
        bytes32 reportHash;
        uint256 submittedAt;
        ReportStatus status;
    }

    mapping(uint256 => Program) private programs;

    mapping(uint256 => mapping(uint256 => Report))
        private reports;

    mapping(uint256 => uint256) public reportCount;

    mapping(uint256 => mapping(bytes32 => bool))
        public reportHashUsed;

    uint256 public programCount;

    event ProgramCreated(
        uint256 indexed programId,
        address indexed owner,
        string title
    );

    event ProgramStatusChanged(
        uint256 indexed programId,
        bool active
    );

    event ReportSubmitted(
        uint256 indexed programId,
        uint256 indexed reportId,
        address indexed reporter,
        bytes32 reportHash
    );

    event ReportStatusChanged(
        uint256 indexed programId,
        uint256 indexed reportId,
        ReportStatus status
    );

    function createProgram(
        string calldata title,
        bytes32 scopeHash
    ) external returns (uint256) {
        require(bytes(title).length > 0, "Empty title");
        require(scopeHash != bytes32(0), "Invalid scope hash");

        uint256 id = programCount;

        programs[id] = Program({
            owner: msg.sender,
            title: title,
            scopeHash: scopeHash,
            createdAt: block.timestamp,
            active: true
        });

        programCount++;

        emit ProgramCreated(id, msg.sender, title);

        return id;
    }

    function setProgramActive(
        uint256 programId,
        bool active
    ) external {
        require(programId < programCount, "Invalid program");

        Program storage program = programs[programId];

        require(program.owner == msg.sender, "Not program owner");

        program.active = active;

        emit ProgramStatusChanged(programId, active);
    }

    function submitReport(
        uint256 programId,
        bytes32 reportHash
    ) external returns (uint256) {
        require(programId < programCount, "Invalid program");

        require(programs[programId].active, "Program inactive");
        require(reportHash != bytes32(0), "Invalid report hash");

        require(
            !reportHashUsed[programId][reportHash],
            "Report already registered"
        );

        uint256 id = reportCount[programId];

        reports[programId][id] = Report({
            reporter: msg.sender,
            reportHash: reportHash,
            submittedAt: block.timestamp,
            status: ReportStatus.Submitted
        });

        reportHashUsed[programId][reportHash] = true;
        reportCount[programId]++;

        emit ReportSubmitted(
            programId,
            id,
            msg.sender,
            reportHash
        );

        return id;
    }

    function setReportStatus(
        uint256 programId,
        uint256 reportId,
        ReportStatus nextStatus
    ) external {
        require(programId < programCount, "Invalid program");

        require(
            reportId < reportCount[programId],
            "Invalid report"
        );

        require(
            programs[programId].owner == msg.sender,
            "Not program owner"
        );

        require(
            nextStatus != ReportStatus.Submitted,
            "Invalid status"
        );

        Report storage report = reports[programId][reportId];

        if (report.status == ReportStatus.Submitted) {
            // Submitted may transition to any non-Submitted status.
        } else if (report.status == ReportStatus.Triaged) {
            require(
                nextStatus == ReportStatus.Accepted ||
                nextStatus == ReportStatus.Rejected ||
                nextStatus == ReportStatus.Resolved,
                "Invalid transition"
            );
        } else if (report.status == ReportStatus.Accepted) {
            require(
                nextStatus == ReportStatus.Resolved,
                "Invalid transition"
            );
        } else {
            revert("Report finalized");
        }

        report.status = nextStatus;

        emit ReportStatusChanged(
            programId,
            reportId,
            nextStatus
        );
    }

    function getProgram(
        uint256 programId
    )
        external
        view
        returns (
            address owner,
            string memory title,
            bytes32 scopeHash,
            uint256 createdAt,
            bool active
        )
    {
        require(programId < programCount, "Invalid program");

        Program memory program = programs[programId];

        return (
            program.owner,
            program.title,
            program.scopeHash,
            program.createdAt,
            program.active
        );
    }

    function getReport(
        uint256 programId,
        uint256 reportId
    )
        external
        view
        returns (
            address reporter,
            bytes32 reportHash,
            uint256 submittedAt,
            ReportStatus status
        )
    {
        require(programId < programCount, "Invalid program");
        require(
            reportId < reportCount[programId],
            "Invalid report"
        );

        Report memory report = reports[programId][reportId];

        return (
            report.reporter,
            report.reportHash,
            report.submittedAt,
            report.status
        );
    }
}
