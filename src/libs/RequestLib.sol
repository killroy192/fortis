// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library RequestLib {
    error DuplicatedRequestCreation(bytes32 id);

    event RequestAdded(address indexed emitter, uint256 blockNumber);
    event RequestFulfilled(address indexed emitter, uint256 blockNumber);

    enum RequestStatus {
        Init,
        Pending,
        Fulfilled
    }

    struct RequestStats {
        RequestStatus status;
        uint256 blockNumber;
        uint256 executionFee;
    }

    struct Requests {
        mapping(bytes32 => RequestStats) requests;
    }

    function generateId(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encode(callbackContract, callbackArgs, nonce, sender)
            );
    }

    function addRequest(
        Requests storage requests,
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool) {
        bytes32 id = generateId(callbackContract, callbackArgs, nonce, sender);
        if (requests.requests[id].status == RequestStatus.Pending) {
            revert DuplicatedRequestCreation(id);
        }
        requests.requests[id] = RequestStats({
            status: RequestStatus.Pending,
            blockNumber: block.number,
            executionFee: msg.value
        });
        emit RequestAdded(msg.sender, block.number);
        return true;
    }

    function fulfillRequest(
        Requests storage requests,
        bytes32 _id
    ) external returns (bool) {
        requests.requests[_id] = RequestStats({
            status: RequestStatus.Fulfilled,
            blockNumber: block.number,
            executionFee: requests.requests[_id].executionFee
        });
        emit RequestFulfilled(msg.sender, block.number);
        return true;
    }

    function getRequest(
        Requests storage requests,
        bytes32 _id
    ) external view returns (RequestStats memory) {
        return requests.requests[_id];
    }
}
