```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseReferral {
    mapping(address => address) public referrer;
    mapping(address => uint256) public referrals;

    uint256 public totalReferrals;

    function setReferrer(address _referrer) external {
        require(_referrer != address(0), "Invalid referrer");
        require(_referrer != msg.sender, "Cannot refer yourself");
        require(referrer[msg.sender] == address(0), "Already has referrer");

        referrer[msg.sender] = _referrer;
        referrals[_referrer]++;
        totalReferrals++;
    }

    function getReferrer(address user) external view returns (address) {
        return referrer[user];
    }

    function getReferralCount(address user) external view returns (uint256) {
        return referrals[user];
    }
}
```
