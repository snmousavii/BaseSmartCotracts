// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCarbonLedger {

    struct Project {
        address issuer;
        string name;
        bytes32 methodologyHash;
        uint256 totalIssued;
        uint256 totalRetired;
        bool active;
        bool exists;
    }

    mapping(uint256 => Project) private projects;

    mapping(uint256 => mapping(address => uint256))
        public balances;

    uint256 public projectCount;

    event ProjectRegistered(
        uint256 indexed projectId,
        address indexed issuer,
        string name
    );

    event CreditsIssued(
        uint256 indexed projectId,
        address indexed recipient,
        uint256 amount
    );

    event CreditsTransferred(
        uint256 indexed projectId,
        address indexed from,
        address indexed to,
        uint256 amount
    );

    event CreditsRetired(
        uint256 indexed projectId,
        address indexed holder,
        uint256 amount
    );

    event ProjectStatusChanged(
        uint256 indexed projectId,
        bool active
    );

    function registerProject(
        string calldata name,
        bytes32 methodologyHash
    ) external returns (uint256) {
        require(bytes(name).length > 0, "Empty name");
        require(methodologyHash != bytes32(0), "Invalid hash");

        uint256 id = projectCount;

        projects[id] = Project({
            issuer: msg.sender,
            name: name,
            methodologyHash: methodologyHash,
            totalIssued: 0,
            totalRetired: 0,
            active: true,
            exists: true
        });

        projectCount++;

        emit ProjectRegistered(id, msg.sender, name);

        return id;
    }

    function issueCredits(
        uint256 projectId,
        address recipient,
        uint256 amount
    ) external {
        require(projectId < projectCount, "Invalid project");

        Project storage project = projects[projectId];

        require(project.issuer == msg.sender, "Not issuer");
        require(project.active, "Project inactive");
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");

        balances[projectId][recipient] += amount;
        project.totalIssued += amount;

        emit CreditsIssued(projectId, recipient, amount);
    }

    function transferCredits(
        uint256 projectId,
        address recipient,
        uint256 amount
    ) external {
        require(projectId < projectCount, "Invalid project");
        require(recipient != address(0), "Invalid recipient");
        require(recipient != msg.sender, "Self transfer");
        require(amount > 0, "Invalid amount");

        require(
            balances[projectId][msg.sender] >= amount,
            "Insufficient balance"
        );

        balances[projectId][msg.sender] -= amount;
        balances[projectId][recipient] += amount;

        emit CreditsTransferred(
            projectId,
            msg.sender,
            recipient,
            amount
        );
    }

    function retireCredits(
        uint256 projectId,
        uint256 amount
    ) external {
        require(projectId < projectCount, "Invalid project");
        require(amount > 0, "Invalid amount");

        require(
            balances[projectId][msg.sender] >= amount,
            "Insufficient balance"
        );

        balances[projectId][msg.sender] -= amount;
        projects[projectId].totalRetired += amount;

        emit CreditsRetired(projectId, msg.sender, amount);
    }

    function setProjectActive(
        uint256 projectId,
        bool active
    ) external {
        require(projectId < projectCount, "Invalid project");
        require(
            projects[projectId].issuer == msg.sender,
            "Not issuer"
        );

        projects[projectId].active = active;

        emit ProjectStatusChanged(projectId, active);
    }

    function getProject(
        uint256 projectId
    )
        external
        view
        returns (
            address issuer,
            string memory name,
            bytes32 methodologyHash,
            uint256 totalIssued,
            uint256 totalRetired,
            bool active
        )
    {
        require(projectId < projectCount, "Invalid project");

        Project memory p = projects[projectId];

        return (
            p.issuer,
            p.name,
            p.methodologyHash,
            p.totalIssued,
            p.totalRetired,
            p.active
        );
    }
}
