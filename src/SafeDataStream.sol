// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {IRequestsManager} from "./interfaces/IRequestsManager.sol";

contract SafeDataStream {
    error InvalidRequestsExecution(bytes32 id);

    address public immutable REQUESTS_MANAGER;
    uint256 public immutable REQUEST_TIMOUT;

    constructor(address _requestManager, uint256 _requestTimeout) {
        REQUESTS_MANAGER = _requestManager;
        REQUEST_TIMOUT = _requestTimeout;
    }

    modifier preventDuplicatedExecution(bytes32 _id) {
        IRequestsManager.Request memory req = _getReq(_id);
        if (req.status == 2) {
            revert InvalidRequestsExecution(_id);
        }
        _;
    }

    modifier fallbackExecutionAllowed(bytes32 _id) {
        IRequestsManager.Request memory req = _getReq(_id);
        if (
            req.status != 1 || req.blockNumber + REQUEST_TIMOUT < block.number
        ) {
            revert InvalidRequestsExecution(_id);
        }
        _;
    }

    function fulfillRequest(bytes32 _id) internal {
        IRequestsManager(REQUESTS_MANAGER).fulfillRequest(address(this), _id);
    }

    function _getReq(
        bytes32 _id
    ) private view returns (IRequestsManager.Request memory) {
        return
            IRequestsManager(REQUESTS_MANAGER).getRequest(address(this), _id);
    }
}
