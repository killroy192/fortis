// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IRequestsManager {
    enum RequestStatus {
        Init,
        Pending,
        Fulfilled
    }

    struct Request {
        RequestStatus status;
        uint256 blockNumber;
    }

    function addRequest(bytes32 _id) external;

    function fulfillRequest(bytes32 _id) external;

    function getRequest(bytes32 _id) external view returns (Request memory);
}
