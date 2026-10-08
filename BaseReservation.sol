// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseReservation {

    struct Reservation {
        uint256 id;
        uint256 resourceId;
        address user;
        uint256 startTime;
        uint256 endTime;
        bool cancelled;
    }

    Reservation[] public reservations;

    event ReservationCreated(
        uint256 indexed reservationId,
        uint256 indexed resourceId,
        address indexed user,
        uint256 startTime,
        uint256 endTime
    );

    event ReservationCancelled(
        uint256 indexed reservationId,
        address indexed user
    );

    function createReservation(
        uint256 resourceId,
        uint256 startTime,
        uint256 endTime
    ) external {
        require(endTime > startTime, "Invalid time range");
        require(startTime > block.timestamp, "Start must be future");

        for (uint256 i = 0; i < reservations.length; i++) {
            Reservation memory current = reservations[i];

            if (
                current.resourceId == resourceId &&
                !current.cancelled &&
                current.endTime > block.timestamp &&
                startTime < current.endTime &&
                endTime > current.startTime
            ) {
                revert("Time slot unavailable");
            }
        }

        uint256 reservationId = reservations.length;

        reservations.push(
            Reservation({
                id: reservationId,
                resourceId: resourceId,
                user: msg.sender,
                startTime: startTime,
                endTime: endTime,
                cancelled: false
            })
        );

        emit ReservationCreated(
            reservationId,
            resourceId,
            msg.sender,
            startTime,
            endTime
        );
    }

    function cancelReservation(
        uint256 reservationId
    ) external {
        require(
            reservationId < reservations.length,
            "Invalid reservation"
        );

        Reservation storage reservation = reservations[reservationId];

        require(
            reservation.user == msg.sender,
            "Not reservation owner"
        );

        require(
            !reservation.cancelled,
            "Already cancelled"
        );

        reservation.cancelled = true;

        emit ReservationCancelled(
            reservationId,
            msg.sender
        );
    }

    function getReservation(
        uint256 reservationId
    )
        external
        view
        returns (
            uint256 id,
            uint256 resourceId,
            address user,
            uint256 startTime,
            uint256 endTime,
            bool cancelled
        )
    {
        require(
            reservationId < reservations.length,
            "Invalid reservation"
        );

        Reservation memory reservation = reservations[reservationId];

        return (
            reservation.id,
            reservation.resourceId,
            reservation.user,
            reservation.startTime,
            reservation.endTime,
            reservation.cancelled
        );
    }

    function totalReservations()
        external
        view
        returns (uint256)
    {
        return reservations.length;
    }
}
