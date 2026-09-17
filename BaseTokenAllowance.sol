// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20View {
    function balanceOf(address account) external view returns (uint256);
    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);
}

contract BaseTokenAllowance {
    function getBalance(
        address token,
        address account
    ) external view returns (uint256) {
        return IERC20View(token).balanceOf(account);
    }

    function getAllowance(
        address token,
        address owner,
        address spender
    ) external view returns (uint256) {
        return IERC20View(token).allowance(owner, spender);
    }
}
