// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {IAsset} from "./interfaces/IAsset.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";
import {IFeeManager} from "./interfaces/IFeeManager.sol";
import {IOracle} from "./interfaces/IOracle.sol";
import {IOracleConsumerContract, ForwardData, FeedType} from "./interfaces/IOracleCallBackContract.sol";
import {IRequestsManager} from "./interfaces/IRequestsManager.sol";
import {IAutomationEmitter} from "./interfaces/IAutomationEmitter.sol";

import {RequestLib} from "./libs/RequestLib.sol";

import {DataStreamConsumer} from "./DataStreamConsumer.sol";
import {PriceFeedConsumer} from "./PriceFeedConsumer.sol";
import {RequestsManager} from "./RequestsManager.sol";

contract Oracle is IOracle, DataStreamConsumer, PriceFeedConsumer {
    error DuplicatedRequestCreation(bytes32 id);
    error InvalidRequestsExecution(bytes32 id);
    error FailedRequestsConsumption(bytes32 id);

    IAutomationEmitter public immutable emitter;
    IVerifierProxy public immutable verifier;
    RequestsManager public immutable requestManager;
    // blocks from request initialization
    uint256 public immutable requestTimeout;

    // Find a complete list of IDs and verifiers at https://docs.chain.link/data-streams/stream-ids
    constructor(
        address _emmiter,
        address _verifier,
        string memory _dataStreamfeedId,
        address _priceFeedId,
        uint256 _requestTimeout
    ) DataStreamConsumer(_dataStreamfeedId) PriceFeedConsumer(_priceFeedId) {
        emitter = IAutomationEmitter(_emmiter);
        verifier = IVerifierProxy(_verifier);
        requestManager = new RequestsManager();
        requestTimeout = _requestTimeout;
    }

    function _addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) internal {
        (
            bytes32 id,
            IRequestsManager.RequestStats memory reqStats
        ) = getRequestProps(callbackContract, callbackArgs, nonce, sender);
        // prevent duplicated request execution
        if (reqStats.status == IRequestsManager.RequestStatus.Pending) {
            revert DuplicatedRequestCreation(id);
        }
        requestManager.addRequest(id);
    }

    function addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool) {
        _addRequest(callbackContract, callbackArgs, nonce, sender);
        return
            emitter.emitAutomationEvent(
                callbackContract,
                callbackArgs,
                nonce,
                sender
            );
    }

    function performUpkeep(bytes calldata performData) external override {
        // Decode the performData bytes passed in by CL Automation.
        // This contains the data returned by your implementation in checkCallback().
        (bytes[] memory signedReports, bytes memory extraData) = abi.decode(
            performData,
            (bytes[], bytes)
        );

        bytes memory unverifiedReport = signedReports[0];

        (
            address callbackContract,
            bytes memory callbackArgs,
            uint256 nonce,
            address sender
        ) = abi.decode(extraData, (address, bytes, uint256, address));

        (
            bytes32 id,
            IRequestsManager.RequestStats memory reqStats
        ) = getRequestProps(callbackContract, callbackArgs, nonce, sender);

        // prevent duplicated request execution
        if (reqStats.status != IRequestsManager.RequestStatus.Pending) {
            revert InvalidRequestsExecution(id);
        }

        (, /* bytes32[3] reportContextData */ bytes memory reportData) = abi
            .decode(unverifiedReport, (bytes32[3], bytes));

        // Report verification fees
        IFeeManager feeManager = IFeeManager(address(verifier.s_feeManager()));

        address feeTokenAddress = feeManager.i_linkAddress();
        (IAsset memory fee, , ) = feeManager.getFeeAndReward(
            address(this),
            reportData,
            feeTokenAddress
        );

        // Approve rewardManager to spend this contract's balance in fees
        IERC20(feeTokenAddress).approve(
            address(feeManager.i_rewardManager()),
            fee.amount
        );

        // Verify the report
        bytes memory verifiedReportData = verifier.verify(
            unverifiedReport,
            abi.encode(feeTokenAddress)
        );

        // Decode verified report data into BasicReport struct
        BasicReport memory report = abi.decode(
            verifiedReportData,
            (BasicReport)
        );

        bool success = IOracleConsumerContract(callbackContract).consume(
            ForwardData({
                price: int256(report.price),
                feedType: FeedType.DataStream,
                forwardArguments: callbackArgs
            })
        );

        if (!success) {
            revert FailedRequestsConsumption(id);
        }

        requestManager.fulfillRequest(id);
    }

    function fallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool) {
        (bytes32 id, bool executable) = previewFallbackCall(
            callbackContract,
            callbackArgs,
            nonce,
            sender
        );

        if (executable) {
            revert InvalidRequestsExecution(id);
        }

        int256 price = getLatestPrice();

        bool success = IOracleConsumerContract(callbackContract).consume(
            ForwardData({
                price: price,
                feedType: FeedType.PriceFeed,
                forwardArguments: callbackArgs
            })
        );

        if (!success) {
            revert FailedRequestsConsumption(id);
        }

        return requestManager.fulfillRequest(id);
    }

    function previewFallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) public view returns (bytes32, bool) {
        (
            bytes32 id,
            IRequestsManager.RequestStats memory reqStats
        ) = getRequestProps(callbackContract, callbackArgs, nonce, sender);

        bool executable = reqStats.status !=
            IRequestsManager.RequestStatus.Pending ||
            reqStats.blockNumber + requestTimeout < block.number;

        return (id, executable);
    }

    // Utils

    function getRequestProps(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) public view returns (bytes32, RequestsManager.RequestStats memory) {
        bytes32 id = RequestLib.generateId(
            callbackContract,
            callbackArgs,
            nonce,
            sender
        );

        return (id, requestManager.getRequest(id));
    }
}
