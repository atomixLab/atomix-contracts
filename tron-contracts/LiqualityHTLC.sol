// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import './utils/SafeTRC20.sol';
import './LibTransfer.sol';
import './ILiqualityHTLC.sol';


contract TronHTLC is ILiqualityHTLC {
    using SafeERC20 for IERC20;

    mapping(bytes32 => HTLCData) public htlcs;

    function initiate(HTLCData calldata htlc) external payable override returns (bytes32 id) {
        require(htlc.expiration > block.timestamp, "Invalid expiration");
        require(htlc.amount > 0, "Invalid swap amount");

        // Handle TRX swaps
        if (htlc.tokenAddress == address(0)) {
            require(htlc.amount == msg.value, "Invalid msg value");
        } 
        // Handle TRC20 swaps
        else {
            require(msg.value == 0, "Invalid msg value for TRC20");
            IERC20(htlc.tokenAddress).safeTransferFrom(msg.sender, address(this), htlc.amount);
        }

        id = keccak256(abi.encode(htlc.refundAddress, block.timestamp, htlc.amount, htlc.expiration, htlc.secretHash, htlc.recipientAddress));

        require(htlcs[id].expiration == 0, "Swap already exists");

        htlcs[id] = htlc;
        emit Initiate(id, htlc);
    }

    function claim(bytes32 id, bytes32 secret) external override {
        HTLCData memory h = htlcs[id];

        require(h.expiration != 0, "Swap does not exist");
        require(keccak256(abi.encodePacked(secret)) == h.secretHash, "Wrong secret");

        delete htlcs[id];
        emit Claim(id, secret);

        // Handle TRX claims
        if (h.tokenAddress == address(0)) {
            LibTransfer.transferEth(payable(h.recipientAddress), h.amount);
        } 
        // Handle TRC20 claims
        else {
            IERC20(h.tokenAddress).safeTransfer(h.recipientAddress, h.amount);
        }
    }

    function refund(bytes32 id) external override {
        HTLCData memory h = htlcs[id];

        require(h.expiration != 0, "Swap does not exist");
        require(block.timestamp > h.expiration, "Swap not expired");

        delete htlcs[id];
        emit Refund(id);

        // Handle TRX refunds
        if (h.tokenAddress == address(0)) {
            LibTransfer.transferEth(payable(h.refundAddress), h.amount);
        } 
        // Handle TRC20 refunds
        else {
            IERC20(h.tokenAddress).safeTransfer(h.refundAddress, h.amount);
        }
    }
}
