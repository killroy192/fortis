// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console

import "@std/Test.sol";

import {RequestLib} from "src/libs/RequestLib.sol";

contract RequestsLibTest is Test {
    event RequestAdded(address indexed emitter, uint256 blockNumber);
    event RequestFulfilled(address indexed emitter, uint256 blockNumber);

    address private callbackContract = address(1);
    bytes private callbackArgs = "";
    uint256 private nonce = 0;
    address private sender;
    RequestLib.Requests private requests;
    bytes32 private id;

    function aseertEqRequests(
        RequestLib.RequestStats memory req0,
        RequestLib.RequestStats memory req1
    ) internal {
        assertEq(abi.encode(req0), abi.encode(req1));
    }

    function setUp() public {
        id = RequestLib.generateId(
            callbackContract,
            callbackArgs,
            nonce,
            msg.sender
        );
        requests.requests[id] = RequestLib.RequestStats({
            status: RequestLib.RequestStatus.Init,
            blockNumber: 0,
            executionFee: 0
        });
    }

    function test_generateId() public {
        assertEq(
            abi.encode(id),
            abi.encode(
                keccak256(
                    abi.encode(
                        callbackContract,
                        callbackArgs,
                        nonce,
                        msg.sender
                    )
                )
            )
        );
    }

    function test_getRequestDefault() public {
        aseertEqRequests(
            RequestLib.getRequest(requests, id),
            RequestLib.RequestStats({
                status: RequestLib.RequestStatus.Init,
                blockNumber: 0,
                executionFee: 0
            })
        );
    }

    function test_addRequest() public {
        // fake block.number
        vm.roll(50);

        // config to expect emit proper event
        vm.expectEmit(true, true, false, false);
        emit RequestAdded(msg.sender, 50);

        // execution
        RequestLib.addRequest(
            requests,
            callbackContract,
            callbackArgs,
            nonce,
            msg.sender
        );

        // check result
        aseertEqRequests(
            RequestLib.getRequest(requests, id),
            RequestLib.RequestStats({
                status: RequestLib.RequestStatus.Pending,
                blockNumber: 50,
                executionFee: 0
            })
        );
    }

    function test_fulfillRequest() public {
        // fake block.number
        vm.roll(39);
        // add request
        RequestLib.addRequest(
            requests,
            callbackContract,
            callbackArgs,
            nonce,
            msg.sender
        );

        // config to expect emit proper event
        vm.expectEmit(true, true, false, false);
        emit RequestFulfilled(msg.sender, 39);

        // execution
        RequestLib.fulfillRequest(requests, id);

        // check result
        aseertEqRequests(
            RequestLib.getRequest(requests, id),
            RequestLib.RequestStats({
                status: RequestLib.RequestStatus.Fulfilled,
                blockNumber: 39,
                executionFee: 0
            })
        );
    }
}
