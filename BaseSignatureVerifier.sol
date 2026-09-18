// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseSignatureVerifier {
    function messageHash(string calldata message)
        public
        pure
        returns (bytes32)
    {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n",
                _toString(bytes(message).length),
                message
            )
        );
    }

    function recoverSigner(
        string calldata message,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public pure returns (address) {
        return ecrecover(
            messageHash(message),
            v,
            r,
            s
        );
    }

    function verify(
        string calldata message,
        address expectedSigner,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external pure returns (bool) {
        return recoverSigner(message, v, r, s) == expectedSigner;
    }

    function _toString(uint256 value)
        internal
        pure
        returns (string memory)
    {
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
