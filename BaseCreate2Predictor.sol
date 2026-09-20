// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCreate2Predictor {
    function predictAddress(
        address deployer,
        bytes32 salt,
        bytes32 initCodeHash
    ) external pure returns (address) {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                deployer,
                salt,
                initCodeHash
            )
        );

        return address(uint160(uint256(hash)));
    }
}
