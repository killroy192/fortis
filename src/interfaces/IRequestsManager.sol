// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IRequestsManager {
    struct Request {
        // 0 - init, 1 - pending, 2 - closed
        uint8 status;
        uint256 blockNumber;
    }

    error Unauthorized();
    error Forbidden();

    function register(address _stremUpKeep, address _emitter) external;

    function unRegister(address _stremUpKeep) external;

    function getEmitter(address _stremUpKeep) external view returns (address);

    function addRequest(bytes32 _id) external;

    function fulfillRequest(address _emitter, bytes32 _id) external;

    function getRequest(
        address _emitter,
        bytes32 _id
    ) external view returns (Request memory);
}
