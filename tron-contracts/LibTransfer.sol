// SPDX-License-Identifier: MIT
pragma solidity >=0.8.11;

library LibTransfer {
    function transferEth(address payable to, uint256 value) internal {
        (bool success, ) = to.call{ value: value }('');
        require(success, "Transfer failed");
    }
}
