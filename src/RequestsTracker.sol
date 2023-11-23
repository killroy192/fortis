// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {IRequestsManager} from "./interfaces/IRequestsManager.sol";

contract RequestsTracker {
    address public immutable REQUESTS_MANAGER;

    constructor(address _requestManager) {
        REQUESTS_MANAGER = _requestManager;
    }

    function trackRequest(bytes32 _id) internal {
        IRequestsManager(REQUESTS_MANAGER).addRequest(_id);
    }
}
