// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console
// solhint-disable explicit-types

import "@std/Test.sol";

import {Oracle} from "src/Oracle.sol";
import {AutomationEmitter} from "src/AutomationEmitter.sol";
import {IAutomationRegistry} from "src/interfaces/IAutomationRegistry.sol";

contract MockLinkDataFeed {
    function latestRoundData()
        external
        pure
        returns (
            uint80 roundId,
            int256 answer,
            uint startedAt,
            uint updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, 6 * 10 ** 14, 0, 0, 0);
    }
}

contract MockUSDDataFeed {
    function latestRoundData()
        external
        pure
        returns (
            uint80 roundId,
            int256 answer,
            uint startedAt,
            uint updatedAt,
            uint80 answeredInRound
        )
    {
        return (0, 228173129000, 0, 0, 0);
    }
}

contract MockLinkToken {
    function transferFrom(address, address, uint) external returns (bool) {
        return true;
    }

    function transferAndCall(
        address,
        uint,
        bytes calldata
    ) external returns (bool) {
        return true;
    }

    function approve(address, uint) external returns (bool) {
        return true;
    }
}

contract MockRegistry is IAutomationRegistry {
    // solhint-disable-next-line no-empty-blocks
    function addFunds(uint256 id, uint96 amount) external {}
}

contract OracleTest is Test {
    event AutomationTrigger(
        address callBackContract,
        bytes callBackArgs,
        uint nonce,
        address sender
    );

    event SetOracleId(uint id);

    Oracle private oracle;
    MockLinkDataFeed private LINK_ETH_data_dfeed = new MockLinkDataFeed();
    MockUSDDataFeed private ETH_USD_data_feed = new MockUSDDataFeed();
    MockLinkToken private linkToken = new MockLinkToken();
    MockRegistry private registry = new MockRegistry();
    AutomationEmitter private emitter;

    function setUp() public {
        emitter = new AutomationEmitter();
        oracle = new Oracle(
            address(emitter),
            address(0),
            "test",
            address(ETH_USD_data_feed),
            address(LINK_ETH_data_dfeed),
            address(linkToken),
            address(registry),
            10
        );

        payable(address(oracle)).call{value: 24 * 10 ** 15}("");
    }

    function test_onRegister() public {
        uint id = 123456343414215;
        vm.expectEmit();
        emit SetOracleId(id);

        oracle.onRegister(id);
    }

    function test_addRequest() public {
        vm.expectEmit();
        emit AutomationTrigger(
            address(this),
            abi.encodePacked("test"),
            0,
            address(this)
        );

        oracle.addRequest{value: 1 * 10 ** 16}(
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

        oracle.addRequest{value: 1 * 10 ** 16}(
            address(this),
            abi.encodePacked("test"),
            0,
            address(this)
        );

        vm.expectRevert();
        oracle.addRequest{value: 1 * 10 ** 16}(
            address(this),
            abi.encodePacked("test"),
            0,
            address(this)
        );
    }

    function test_swapPreview() public {
        uint amount = 1 * 10 ** 18;
        (bool doTransfer, uint reward) = oracle.swapPreview(amount);
        assertEq(doTransfer, true);
        assertEq(reward, 63 * 10 ** 13);
    }

    function test_swap() public {
        uint amount = 1 * 10 ** 18;
        (, uint reward) = oracle.swapPreview(amount);
        oracle.swap(address(1), amount);
        assertEq(address(1).balance, reward);
    }
}
