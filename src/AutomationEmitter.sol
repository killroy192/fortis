// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IAutomationEmitter} from "./interfaces/IAutomationEmitter.sol";

contract AutomationEmitter is IAutomationEmitter {
    function emitAutomationEvent(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool) {
        emit AutomationTrigger(callbackContract, callbackArgs, nonce, sender);
        return true;
    }
}
