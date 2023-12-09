// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

interface IAutomationEmitter {
    event AutomationTrigger(
        address callbackContract,
        bytes callbackArgs,
        uint256 nonce,
        address sender
    );

    function emitAutomationEvent(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool);
}
