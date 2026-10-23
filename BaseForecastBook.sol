// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseForecastBook {

    struct Forecast {
        address forecaster;
        address resolver;
        string statement;
        bytes32 evidenceHash;
        uint256 predictedValue;
        uint256 targetTime;
        uint256 createdAt;
        uint256 resolvedValue;
        bool resolved;
        bool cancelled;
    }

    mapping(uint256 => Forecast) private forecasts;

    uint256 public forecastCount;

    event ForecastCreated(
        uint256 indexed forecastId,
        address indexed forecaster,
        address indexed resolver,
        uint256 predictedValue,
        uint256 targetTime
    );

    event ForecastResolved(
        uint256 indexed forecastId,
        uint256 predictedValue,
        uint256 actualValue
    );

    event ForecastCancelled(
        uint256 indexed forecastId
    );

    function createForecast(
        string calldata statement,
        uint256 predictedValue,
        uint256 targetTime,
        address resolver,
        bytes32 evidenceHash
    ) external returns (uint256) {
        require(bytes(statement).length > 0, "Empty statement");
        require(targetTime > block.timestamp, "Target must be future");
        require(resolver != address(0), "Invalid resolver");
        require(resolver != msg.sender, "Resolver must differ");

        uint256 id = forecastCount;

        forecasts[id] = Forecast({
            forecaster: msg.sender,
            resolver: resolver,
            statement: statement,
            evidenceHash: evidenceHash,
            predictedValue: predictedValue,
            targetTime: targetTime,
            createdAt: block.timestamp,
            resolvedValue: 0,
            resolved: false,
            cancelled: false
        });

        forecastCount++;

        emit ForecastCreated(
            id,
            msg.sender,
            resolver,
            predictedValue,
            targetTime
        );

        return id;
    }

    function resolveForecast(
        uint256 forecastId,
        uint256 actualValue
    ) external {
        require(forecastId < forecastCount, "Invalid forecast");

        Forecast storage f = forecasts[forecastId];

        require(msg.sender == f.resolver, "Not resolver");
        require(!f.resolved, "Already resolved");
        require(!f.cancelled, "Forecast cancelled");
        require(block.timestamp >= f.targetTime, "Too early");

        f.resolvedValue = actualValue;
        f.resolved = true;

        emit ForecastResolved(
            forecastId,
            f.predictedValue,
            actualValue
        );
    }

    function cancelForecast(uint256 forecastId) external {
        require(forecastId < forecastCount, "Invalid forecast");

        Forecast storage f = forecasts[forecastId];

        require(msg.sender == f.forecaster, "Not forecaster");
        require(!f.resolved, "Already resolved");
        require(!f.cancelled, "Already cancelled");
        require(block.timestamp < f.targetTime, "Target time reached");

        f.cancelled = true;

        emit ForecastCancelled(forecastId);
    }

    function getAbsoluteError(
        uint256 forecastId
    ) external view returns (uint256) {
        require(forecastId < forecastCount, "Invalid forecast");

        Forecast memory f = forecasts[forecastId];

        require(f.resolved, "Not resolved");

        if (f.predictedValue >= f.resolvedValue) {
            return f.predictedValue - f.resolvedValue;
        }

        return f.resolvedValue - f.predictedValue;
    }

    function getForecast(
        uint256 forecastId
    )
        external
        view
        returns (
            address forecaster,
            address resolver,
            string memory statement,
            bytes32 evidenceHash,
            uint256 predictedValue,
            uint256 targetTime,
            uint256 createdAt,
            uint256 resolvedValue,
            bool resolved,
            bool cancelled
        )
    {
        require(forecastId < forecastCount, "Invalid forecast");

        Forecast memory f = forecasts[forecastId];

        return (
            f.forecaster,
            f.resolver,
            f.statement,
            f.evidenceHash,
            f.predictedValue,
            f.targetTime,
            f.createdAt,
            f.resolvedValue,
            f.resolved,
            f.cancelled
        );
    }
}
