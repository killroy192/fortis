// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {IRequestsManager} from "./interfaces/IRequestsManager.sol";

abstract contract GaranteedExecution {
    error InvalidRequestsExecution(bytes32 id);

    uint256 public immutable REQUEST_TIMOUT;

    constructor(uint256 _requestTimeout) {
        REQUEST_TIMOUT = _requestTimeout;
    }

    modifier preventDuplicatedExecution(bytes32 _id) {
        IRequestsManager.Request memory req = getRequest(_id);
        if (req.status == 2) {
            revert InvalidRequestsExecution(_id);
        }
        _;
    }

    modifier fallbackExecutionAllowed(bytes32 _id) {
        IRequestsManager.Request memory req = getRequest(_id);
        if (
            req.status != 1 || req.blockNumber + REQUEST_TIMOUT < block.number
        ) {
            revert InvalidRequestsExecution(_id);
        }
        _;
    }

    function getRequest(
        bytes32 _id
    ) public view virtual returns (IRequestsManager.Request memory);
}
