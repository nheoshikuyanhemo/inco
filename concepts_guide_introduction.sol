// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {euint256, ebool, e} from "@inco/lightning/Lib.sol";

contract SimpleConfidentialToken {
    using e for *;

    mapping(address => euint256) public balanceOf;

    constructor() {
        balanceOf[msg.sender] = uint256(1000 * 1e9).asEuint256();
    }

    function transfer(
        address to,
        bytes memory valueInput
    ) external returns (ebool) {
        euint256 value = valueInput.newEuint256(msg.sender);
        return _transfer(to, value);
    }

    function transfer(
        address to,
        euint256 value
    ) public returns (ebool success) {
        require(
            msg.sender.isAllowed(value),
            "SimpleConfidentialToken: unauthorized value handle access"
        );

        return _transfer(to, value);
    }

    function _transfer(
        address to,
        euint256 value
    ) external returns (ebool success) {
        success = balanceOf[msg.sender].ge(value);
        euint256 transferredValue = success.select(
            value,
            uint256(0).asEuint256()
        );

        euint256 senderNewBalance = balanceOf[msg.sender].sub(transferredValue);
        euint256 receiverNewBalance = balanceOf[to].add(transferredValue);

        balanceOf[msg.sender] = senderNewBalance;
        balanceOf[to] = receiverNewBalance;

        senderNewBalance.allow(msg.sender);
        receiverNewBalance.allow(to);
        senderNewBalance.allowThis();
        receiverNewBalance.allowThis();
    }
}
