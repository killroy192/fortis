// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console

import "@std/Test.sol";
import {RequestsManager} from "src/RequestsManager.sol";
import {IRequestsManager} from "src/interfaces/IRequestsManager.sol";

contract RequestsManagerTest is Test {
    event RequestAdded(address indexed emitter, uint256 blockNumber);
    event RequestFulfilled(address indexed emitter, uint256 blockNumber);

    RequestsManager private manager;
    bytes32 private id;

    function aseertEqRequests(
        IRequestsManager.RequestStats memory req0,
        IRequestsManager.RequestStats memory req1
    ) internal {
        assertEq(abi.encode(req0), abi.encode(req1));
    }

    function setUp() public {
        manager = new RequestsManager();
        id = keccak256(abi.encodePacked(this));
    }

    function test_getRequestDefault() public {
        aseertEqRequests(
            manager.getRequest(id),
            IRequestsManager.RequestStats({
                status: IRequestsManager.RequestStatus.Init,
                blockNumber: 0
            })
        );
    }

    function test_addRequest() public {
        // fake block.number
        vm.roll(50);

        // config to expect emit proper event
        vm.expectEmit(true, true, false, false);
        emit RequestAdded(address(this), 50);

        // execution
        manager.addRequest(id);

        // console.log("request creation block number %s", manager.getRequest(id).blockNumber);
        // check result
        aseertEqRequests(
            manager.getRequest(id),
            IRequestsManager.RequestStats({
                status: IRequestsManager.RequestStatus.Pending,
                blockNumber: 50
            })
        );
    }

    function test_fulfillRequest() public {
        // fake block.number
        vm.roll(39);
        // add request
        manager.addRequest(id);

        // config to expect emit proper event
        vm.expectEmit(true, true, false, false);
        emit RequestFulfilled(address(this), 39);

        // execution
        manager.fulfillRequest(id);

        // check result
        aseertEqRequests(
            manager.getRequest(id),
            IRequestsManager.RequestStats({
                status: IRequestsManager.RequestStatus.Fulfilled,
                blockNumber: 39
            })
        );
    }
}
