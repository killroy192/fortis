// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IAutomationRequestsStore {
    error Unauthorized();
    error Forbidden();

    function register(address _stremUpKeep, address _emitter) external;

    function getEmitter(address _stremUpKeep) external view returns (address);

    function addRequest(address _initiator) external;

    function removeRequest(address _emitter, address _initiator) external;

    function requestStatus(
        address _emitter,
        address _initiator
    ) external view returns (bool hasPendingRequest, uint256 blockNumber);
}
