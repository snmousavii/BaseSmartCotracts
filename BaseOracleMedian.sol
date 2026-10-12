// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseOracleMedian {

    uint256 public constant MAX_REPORTS = 51;

    struct Round {
        address creator;
        string feedName;
        uint256 deadline;
        uint256 reportCount;
    }

    mapping(uint256 => Round) private rounds;

    mapping(uint256 => mapping(address => bool))
        public hasReported;

    mapping(uint256 => uint256[]) private roundReports;

    uint256 public roundCount;

    event RoundCreated(
        uint256 indexed roundId,
        address indexed creator,
        string feedName,
        uint256 deadline
    );

    event ReportSubmitted(
        uint256 indexed roundId,
        address indexed reporter,
        uint256 value
    );

    function createRound(
        string calldata feedName,
        uint256 deadline
    ) external returns (uint256) {
        require(bytes(feedName).length > 0, "Empty feed name");
        require(deadline > block.timestamp, "Invalid deadline");

        uint256 id = roundCount;

        rounds[id] = Round({
            creator: msg.sender,
            feedName: feedName,
            deadline: deadline,
            reportCount: 0
        });

        roundCount++;

        emit RoundCreated(
            id,
            msg.sender,
            feedName,
            deadline
        );

        return id;
    }

    function submitReport(
        uint256 roundId,
        uint256 value
    ) external {
        require(roundId < roundCount, "Invalid round");

        Round storage currentRound = rounds[roundId];

        require(
            block.timestamp < currentRound.deadline,
            "Round ended"
        );

        require(
            !hasReported[roundId][msg.sender],
            "Already reported"
        );

        require(
            roundReports[roundId].length < MAX_REPORTS,
            "Round is full"
        );

        hasReported[roundId][msg.sender] = true;

        roundReports[roundId].push(value);
        currentRound.reportCount++;

        emit ReportSubmitted(
            roundId,
            msg.sender,
            value
        );
    }

    function getMedian(
        uint256 roundId
    ) external view returns (uint256) {
        require(roundId < roundCount, "Invalid round");

        require(
            block.timestamp >= rounds[roundId].deadline,
            "Round still active"
        );

        uint256[] memory sortedValues = roundReports[roundId];
        uint256 length = sortedValues.length;

        require(length > 0, "No reports");

        // Insertion sort; report count is capped at 51.
        for (uint256 i = 1; i < length; i++) {
            uint256 currentValue = sortedValues[i];
            uint256 j = i;

            while (
                j > 0 &&
                sortedValues[j - 1] > currentValue
            ) {
                sortedValues[j] = sortedValues[j - 1];
                j--;
            }

            sortedValues[j] = currentValue;
        }

        if (length % 2 == 1) {
            return sortedValues[length / 2];
        }

        uint256 lower = sortedValues[length / 2 - 1];
        uint256 upper = sortedValues[length / 2];

        return lower + (upper - lower) / 2;
    }

    function getRoundInfo(
        uint256 roundId
    )
        external
        view
        returns (
            address creator,
            string memory feedName,
            uint256 deadline,
            uint256 reportCount
        )
    {
        require(roundId < roundCount, "Invalid round");

        Round memory currentRound = rounds[roundId];

        return (
            currentRound.creator,
            currentRound.feedName,
            currentRound.deadline,
            currentRound.reportCount
        );
    }

    function getReport(
        uint256 roundId,
        uint256 index
    ) external view returns (uint256) {
        require(roundId < roundCount, "Invalid round");
        require(
            index < roundReports[roundId].length,
            "Invalid index"
        );

        return roundReports[roundId][index];
    }
}
