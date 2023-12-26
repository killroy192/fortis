// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console
// solhint-disable explicit-types

import "@std/Test.sol";

import {LinkToken} from "@chainlink/contracts/src/v0.8/shared/token/ERC677/LinkToken.sol";

import {Oracle} from "src/Oracle.sol";
import {AutomationEmitter} from "src/AutomationEmitter.sol";
import {IOracleConsumerContract} from "src/interfaces/IOracleCallBackContract.sol";
import {MockLinkDataFeed, MockUSDDataFeed} from "./mocks/MockDataFeeds.sol";
import {MockRegistry} from "./mocks/MockRegistry.sol";
import {MockVerifier} from "./mocks/MockVerifier.sol";

contract OracleTest is Test {
    event AutomationTrigger(
        address callBackContract, bytes callBackArgs, uint256 nonce, address sender
    );

    event SetOracleId(uint256 id);

    Oracle private oracle;
    MockLinkDataFeed private LINK_ETH_data_dfeed = new MockLinkDataFeed();
    MockUSDDataFeed private ETH_USD_data_feed = new MockUSDDataFeed();
    LinkToken private linkToken = new LinkToken();
    MockRegistry private registry = new MockRegistry();
    MockVerifier private verifier = new MockVerifier();
    AutomationEmitter private emitter = new AutomationEmitter();
    uint256 private paymentForExecution = 1 * 10 ** 16;
    uint256 private linkHoldings;

    address private CALLBACK_CONTRACT = address(3);
    address private SENDER = address(4);

    function setUp() public {
        oracle = new Oracle(
            address(emitter),
            address(verifier),
            "test",
            address(ETH_USD_data_feed),
            address(LINK_ETH_data_dfeed),
            address(linkToken),
            address(registry),
            10
        );

        payable(address(oracle)).call{value: 24 * 10 ** 15}("");

        linkToken.grantMintAndBurnRoles(address(this));
        linkHoldings = 1 * 10 ** linkToken.decimals();
    }

    function test_OnRegister() public {
        uint256 id = 123456343414215;
        vm.expectEmit();
        emit SetOracleId(id);

        oracle.onRegister(id);
    }

    function test_AddRequest() public {
        vm.expectEmit();
        emit AutomationTrigger(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);

        oracle.addRequest{value: 1 * 10 ** 16}(
            CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER
        );
    }

    function test_AddRequestRevertIfDuplicateRequest() public {
        vm.expectEmit();

        emit AutomationTrigger(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);

        oracle.addRequest{value: paymentForExecution}(
            CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER
        );

        vm.expectRevert();
        oracle.addRequest{value: paymentForExecution}(
            CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER
        );
    }

    function test_PreviewFallbackCallIfTimoutHasNotPassed() public {
        oracle.addRequest{value: paymentForExecution}(
            CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER
        );

        (, bool executable, uint256 executionFee) =
            oracle.previewFallbackCall(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);

        assertEq(executable, false);
        assertEq(executionFee, paymentForExecution);
    }

    function test_PreviewFallbackCall() public {
        oracle.addRequest{value: paymentForExecution}(
            CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER
        );

        vm.roll(12);

        (, bool executable,) =
            oracle.previewFallbackCall(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);

        assertEq(executable, true);
    }

    function test_PerformUpkeep() public {
        oracle.addRequest{value: paymentForExecution}(
            CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER
        );

        vm.roll(12);
        vm.mockCall(
            CALLBACK_CONTRACT,
            abi.encodeWithSelector(IOracleConsumerContract.consume.selector),
            abi.encode(true)
        );

        bytes32[3] memory reportContextData = [bytes32(""), bytes32(""), bytes32("")];
        bytes memory reportData = bytes("");
        bytes[] memory signedReports = new bytes[](1);
        signedReports[0] = (abi.encode(reportContextData, reportData));
        bytes memory extraData = abi.encode(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);

        bytes memory performData = abi.encode(signedReports, extraData);

        vm.mockCall(
            CALLBACK_CONTRACT,
            abi.encodeWithSelector(IOracleConsumerContract.consume.selector),
            abi.encode(true)
        );

        oracle.performUpkeep(performData);

        (, bool executable,) =
            oracle.previewFallbackCall(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);

        assertEq(executable, false);
    }

    function test_Fallback() public {
        oracle.addRequest{value: paymentForExecution}(
            CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER
        );

        vm.roll(12);
        vm.mockCall(
            CALLBACK_CONTRACT,
            abi.encodeWithSelector(IOracleConsumerContract.consume.selector),
            abi.encode(true)
        );
        vm.prank(SENDER);

        oracle.fallbackCall(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);

        assertEq(SENDER.balance, paymentForExecution);
    }

    function test_FallbackRevertIfTimoutHasNotPassed() public {
        oracle.addRequest{value: paymentForExecution}(
            CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER
        );

        vm.expectRevert();

        oracle.fallbackCall(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);
    }

    function test_FallbackRevertIfNoRequest() public {
        vm.expectRevert();
        oracle.fallbackCall(CALLBACK_CONTRACT, abi.encodePacked("test"), 0, SENDER);
    }

    function test_SwapPreview() public {
        (bool doTransfer, uint256 reward) = oracle.swapPreview(linkHoldings);
        assertEq(doTransfer, true);
        assertEq(reward, 63 * 10 ** 13);
    }

    function test_Swap() public {
        linkToken.mint(SENDER, linkHoldings);
        vm.prank(SENDER);
        linkToken.approve(address(oracle), linkHoldings);
        (, uint256 reward) = oracle.swapPreview(linkHoldings);
        oracle.swap(SENDER, linkHoldings);
        assertEq(SENDER.balance, reward);
    }
}
