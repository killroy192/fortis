// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console

import "@std/Test.sol";

import {Oracle} from "../Oracle.sol";

contract OracleTest is Test {
    event AutomationTrigger(
        address callBackContract,
        bytes callBackArgs,
        uint256 nonce,
        address sender
    );

    Oracle private oracle = new Oracle(address(0), "test", address(0), 10);

    function test_addRequest() public {
        vm.expectEmit();
        emit AutomationTrigger(
            address(this),
            abi.encodePacked("test"),
            0,
            address(this)
        );

        oracle.addRequest(
            address(this),
            abi.encodePacked("test"),
            0,
            address(this)
        );
    }

    function test_avoidEmitingDuplicatedRequest() public {
        vm.expectEmit();

        emit AutomationTrigger(
            address(this),
            abi.encodePacked("test"),
            0,
            address(this)
        );

        oracle.addRequest(
            address(this),
            abi.encodePacked("test"),
            0,
            address(this)
        );

        vm.expectRevert();
        oracle.addRequest(
            address(this),
            abi.encodePacked("test"),
            0,
            address(this)
        );
    }
}
