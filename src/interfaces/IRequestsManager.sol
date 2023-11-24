// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IRequestsManager {
    struct Request {
        // 0 - init, 1 - pending, 2 - closed
        uint8 status;
        uint256 blockNumber;
    }

    function addRequest(bytes32 _id) external;

    function fulfillRequest(bytes32 _id) external;

    function getRequest(bytes32 _id) external view returns (Request memory);
}
