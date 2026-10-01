// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseReferral {

    mapping(address => address) public referrer;
    mapping(address => uint256) public referralCount;

    event ReferralRegistered(
        address indexed user,
        address indexed referrer
    );

    function registerReferrer(address _referrer) external {
        require(_referrer != address(0), "Invalid referrer");
        require(_referrer != msg.sender, "Cannot refer yourself");
        require(
            referrer[msg.sender] == address(0),
            "Referrer already registered"
        );

        referrer[msg.sender] = _referrer;
        referralCount[_referrer]++;

        emit ReferralRegistered(msg.sender, _referrer);
    }

    function getReferrer(address user)
        external
        view
        returns (address)
    {
        return referrer[user];
    }

    function getReferralCount(address user)
        external
        view
        returns (uint256)
    {
        return referralCount[user];
    }
}
