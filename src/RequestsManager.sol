// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {IRequestsManager} from "./interfaces/IRequestsManager.sol";

contract RequestsManager is IRequestsManager {
    event RequestAdded(address indexed emitter, uint256 blockNumber);
    event RequestFulfilled(address indexed emitter, uint256 blockNumber);

    // _id => RequestStats
    mapping(bytes32 => RequestStats) private _pendingRequests;

    function addRequest(bytes32 _id) external {
        _pendingRequests[_id] = RequestStats({
            status: IRequestsManager.RequestStatus.Pending,
            blockNumber: block.number
        });
        emit RequestAdded(msg.sender, block.number);
    }

    function fulfillRequest(bytes32 _id) external {
        _pendingRequests[_id] = RequestStats({
            status: IRequestsManager.RequestStatus.Fulfilled,
            blockNumber: block.number
        });
        emit RequestFulfilled(msg.sender, block.number);
    }

    function getRequest(
        bytes32 _id
    ) external view returns (RequestStats memory) {
        return _pendingRequests[_id];
    }
}
