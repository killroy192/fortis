// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.19;

import {IAutomationRequestsStore} from "./interfaces/IAutomationRequestsStore.sol";

contract AutomationRequestsStore is IAutomationRequestsStore {
    event RequestAdded(address indexed emitter, uint256 indexed blockNumber);
    event RequestRemoved(address indexed emitter);

    // _emitter => initiator => inition block number
    mapping(address => mapping(address => uint256)) private _pendingRequests;
    // _stremUpKeep => _emitter
    mapping(address => address) private _registry;

    function register(address _stremUpKeep, address _emitter) external {
        if (getEmitter(_stremUpKeep) != address(0)) {
            revert Forbidden();
        }
        _registry[_stremUpKeep] = _emitter;
    }

    function getEmitter(address _stremUpKeep) public view returns (address) {
        return _registry[_stremUpKeep];
    }

    function addRequest(address _initiator) external {
        _pendingRequests[msg.sender][_initiator] = block.number;
        emit RequestAdded(msg.sender, block.number);
    }

    function removeRequest(address _emitter, address _initiator) external {
        if (_registry[msg.sender] != _emitter) {
            revert Unauthorized();
        }
        _pendingRequests[msg.sender][_initiator] = 0;
        emit RequestRemoved(_emitter);
    }

    function requestStatus(
        address _emitter,
        address _initiator
    ) external view returns (bool hasPendingRequest, uint256 blockNumber) {
        blockNumber = _pendingRequests[_emitter][_initiator];
        hasPendingRequest = blockNumber > 0;
    }
}
