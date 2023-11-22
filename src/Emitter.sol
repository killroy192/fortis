// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.19;

import {IAutomationRequestsStore} from "./interfaces/IAutomationRequestsStore.sol";

contract Emitter {
    event AutomationTrigger(address indexed msgSender);

    // address public immutable requestStore;

    // constructor(address _requestStore) {
    //     requestStore = _requestStore;
    // }

    function emitRequest() external {
        // IAutomationRequestsStore(requestStore).addRequest(msg.sender);
        emit AutomationTrigger(msg.sender);
    }
}
