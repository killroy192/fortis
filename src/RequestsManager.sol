// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {IRequestsManager} from "./interfaces/IRequestsManager.sol";

contract RequestsManager is IRequestsManager {
    event RequestAdded(address indexed emitter, uint256 blockNumber);
    event RequestFulfilled(address indexed emitter, uint256 blockNumber);

    // _emitter => _id => Request
    mapping(address => mapping(bytes32 => Request)) private _pendingRequests;
    // _stremUpKeep => _emitter
    mapping(address => address) private _registry;

    modifier onlyAutohrized(address _emitter) {
        if (_registry[msg.sender] != _emitter) {
            revert Unauthorized();
        }
        _;
    }

    function register(address _stremUpKeep, address _emitter) external {
        if (getEmitter(_stremUpKeep) != address(0)) {
            revert Forbidden();
        }
        _registry[_stremUpKeep] = _emitter;
    }

    function unRegister(address _stremUpKeep) external {
        _registry[_stremUpKeep] = address(0);
    }

    function getEmitter(address _stremUpKeep) public view returns (address) {
        return _registry[_stremUpKeep];
    }

    function addRequest(bytes32 _id) external {
        _pendingRequests[msg.sender][_id] = Request({
            status: 1,
            blockNumber: block.number
        });
        emit RequestAdded(msg.sender, block.number);
    }

    function fulfillRequest(
        address _emitter,
        bytes32 _id
    ) external onlyAutohrized(_emitter) {
        _pendingRequests[_emitter][_id] = Request({
            status: 2,
            blockNumber: block.number
        });
        emit RequestFulfilled(_emitter, block.number);
    }

    function getRequest(
        address _emitter,
        bytes32 _id
    ) external view returns (Request memory) {
        return _pendingRequests[_emitter][_id];
    }
}
