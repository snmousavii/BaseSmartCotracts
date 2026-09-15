// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseSelectorRegistry {
    mapping(bytes4 => string) public selectors;

    function registerSelector(bytes4 selector, string calldata name) external {
        require(bytes(selectors[selector]).length == 0, "Already registered");
        selectors[selector] = name;
    }

    function renameSelector(bytes4 selector, string calldata newName) external {
        require(bytes(selectors[selector]).length != 0, "Not registered");
        selectors[selector] = newName;
    }

    function exists(bytes4 selector) external view returns (bool) {
        return bytes(selectors[selector]).length != 0;
    }
}
