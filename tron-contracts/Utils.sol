// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Utils {
    // Funtion to get the Secret Hash
    function getSecretHash(string memory secret) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(secret));
    }
    
    // Function to return the given address
    function getTokenAddress() public pure returns (address) {
        return address(0);
    }
}
