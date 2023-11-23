// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {RequestsTracker} from "../RequestsTracker.sol";

contract Emitter is RequestsTracker {
    struct GenericRequest {
        address callBackContract;
        bytes callBackArgs;
    }

    event AutomationTrigger(bytes32 id);

    // solhint-disable-next-line no-empty-blocks
    constructor(address _requestManager) RequestsTracker(_requestManager) {}

    function emitRequest(GenericRequest memory request) external {
        bytes32 id = keccak256(abi.encode(request));
        trackRequest(id);
        emit AutomationTrigger(id);
    }
}
