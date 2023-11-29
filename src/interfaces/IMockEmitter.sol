// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {Request} from "./Request.sol";
import {IEmitter} from "./IEmitter.sol";

interface IMockEmitter {
    event FakeAutomationTrigger(Request request);

    function emitFakeRequest(Request memory request) external returns (bool);
}
