// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {Request} from "./Request.sol";

interface IEmitter {
    event AutomationTrigger(bytes32 id);

    function emitRequest(Request memory request) external;
}
