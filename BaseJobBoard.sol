// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseJobBoard {

    enum ApplicationStatus {
        Submitted,
        Shortlisted,
        Rejected,
        Hired,
        Withdrawn
    }

    struct Job {
        address employer;
        string title;
        string description;
        bool isOpen;
        uint256 createdAt;
    }

    struct Application {
        address applicant;
        string coverLetter;
        ApplicationStatus status;
        uint256 appliedAt;
    }

    mapping(uint256 => Job) public jobs;

    mapping(uint256 => Application[]) private applications;

    mapping(uint256 => mapping(address => bool))
        public hasApplied;

    uint256 public jobCount;

    event JobPosted(
        uint256 indexed jobId,
        address indexed employer,
        string title
    );

    event JobClosed(
        uint256 indexed jobId
    );

    event ApplicationSubmitted(
        uint256 indexed jobId,
        uint256 indexed applicationId,
        address indexed applicant
    );

    event ApplicationStatusChanged(
        uint256 indexed jobId,
        uint256 indexed applicationId,
        ApplicationStatus status
    );

    function postJob(
        string calldata title,
        string calldata description
    ) external {
        require(bytes(title).length > 0, "Empty title");
        require(bytes(description).length > 0, "Empty description");

        uint256 id = jobCount;

        jobs[id] = Job({
            employer: msg.sender,
            title: title,
            description: description,
            isOpen: true,
            createdAt: block.timestamp
        });

        jobCount++;

        emit JobPosted(id, msg.sender, title);
    }

    function closeJob(uint256 jobId) external {
        require(jobId < jobCount, "Invalid job");

        Job storage job = jobs[jobId];

        require(job.employer == msg.sender, "Not employer");
        require(job.isOpen, "Job already closed");

        job.isOpen = false;

        emit JobClosed(jobId);
    }

    function submitApplication(
        uint256 jobId,
        string calldata coverLetter
    ) external {
        require(jobId < jobCount, "Invalid job");

        Job storage job = jobs[jobId];

        require(job.isOpen, "Job is closed");
        require(msg.sender != job.employer, "Employer cannot apply");
        require(!hasApplied[jobId][msg.sender], "Already applied");
        require(bytes(coverLetter).length > 0, "Empty cover letter");

        uint256 applicationId = applications[jobId].length;

        applications[jobId].push(
            Application({
                applicant: msg.sender,
                coverLetter: coverLetter,
                status: ApplicationStatus.Submitted,
                appliedAt: block.timestamp
            })
        );

        hasApplied[jobId][msg.sender] = true;

        emit ApplicationSubmitted(
            jobId,
            applicationId,
            msg.sender
        );
    }

    function setApplicationStatus(
        uint256 jobId,
        uint256 applicationId,
        ApplicationStatus nextStatus
    ) external {
        require(jobId < jobCount, "Invalid job");
        require(
            applicationId < applications[jobId].length,
            "Invalid application"
        );

        require(
            jobs[jobId].employer == msg.sender,
            "Not employer"
        );

        require(
            nextStatus == ApplicationStatus.Shortlisted ||
            nextStatus == ApplicationStatus.Rejected ||
            nextStatus == ApplicationStatus.Hired,
            "Invalid status"
        );

        Application storage app =
            applications[jobId][applicationId];

        require(
            app.status == ApplicationStatus.Submitted ||
            app.status == ApplicationStatus.Shortlisted,
            "Application finalized"
        );

        app.status = nextStatus;

        emit ApplicationStatusChanged(
            jobId,
            applicationId,
            nextStatus
        );
    }

    function withdrawApplication(
        uint256 jobId
    ) external {
        require(jobId < jobCount, "Invalid job");

        bool found = false;

        for (
            uint256 i = 0;
            i < applications[jobId].length;
            i++
        ) {
            Application storage app = applications[jobId][i];

            if (app.applicant == msg.sender) {
                require(
                    app.status == ApplicationStatus.Submitted ||
                    app.status == ApplicationStatus.Shortlisted,
                    "Cannot withdraw"
                );

                app.status = ApplicationStatus.Withdrawn;

                emit ApplicationStatusChanged(
                    jobId,
                    i,
                    ApplicationStatus.Withdrawn
                );

                found = true;
                break;
            }
        }

        require(found, "Application not found");
    }

    function getApplicationCount(
        uint256 jobId
    ) external view returns (uint256) {
        require(jobId < jobCount, "Invalid job");
        return applications[jobId].length;
    }

    function getApplication(
        uint256 jobId,
        uint256 applicationId
    )
        external
        view
        returns (
            address applicant,
            string memory coverLetter,
            ApplicationStatus status,
            uint256 appliedAt
        )
    {
        require(jobId < jobCount, "Invalid job");
        require(
            applicationId < applications[jobId].length,
            "Invalid application"
        );

        Application memory app =
            applications[jobId][applicationId];

        return (
            app.applicant,
            app.coverLetter,
            app.status,
            app.appliedAt
        );
    }
}
