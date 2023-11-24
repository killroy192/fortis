// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IEmitter {
    struct GenericRequest {
        address callBackContract;
        bytes callBackArgs;
    }

    event AutomationTrigger(bytes32 id);

    function emitRequest(GenericRequest memory request) external;
}
