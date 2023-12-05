// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IAsset} from "./interfaces/IAsset.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";
import {IFeeManager} from "./interfaces/IFeeManager.sol";
import {IOracle} from "./interfaces/IOracle.sol";
import {IOracleConsumerContract, ForwardData, FeedType} from "./interfaces/IOracleCallBackContract.sol";
import {IAutomationEmitter} from "./interfaces/IAutomationEmitter.sol";

import {RequestLib} from "./libs/RequestLib.sol";
import {FeeManagerLib} from "./libs/FeeManagerLib.sol";

import {DataStreamConsumer} from "./DataStreamConsumer.sol";

contract Oracle is IOracle, DataStreamConsumer, ReentrancyGuard {
    error InvalidRequestsExecution(bytes32 id);
    error FailedRequestsConsumption(bytes32 id);
    error FeeIsTooSmall();

    IAutomationEmitter public immutable emitter;
    IVerifierProxy public immutable verifier;
    AggregatorV3Interface public immutable priceFeed;
    // blocks from request initialization
    uint256 public immutable requestTimeout;

    // fee state
    using FeeManagerLib for FeeManagerLib.FeeState;
    FeeManagerLib.FeeState private _feeState;

    using RequestLib for RequestLib.Requests;
    RequestLib.Requests private _requests;

    // Find a complete list of IDs and verifiers at https://docs.chain.link/data-streams/stream-ids
    constructor(
        address _emmiter,
        address _verifier,
        string memory _dataStreamfeedId,
        address _priceFeed,
        uint256 _requestTimeout
    ) DataStreamConsumer(_dataStreamfeedId) {
        emitter = IAutomationEmitter(_emmiter);
        verifier = IVerifierProxy(_verifier);
        priceFeed = AggregatorV3Interface(_priceFeed);
        requestTimeout = _requestTimeout;
    }

    function handlePayment() public payable returns (bool) {
        if (msg.value < _feeState.processingFee) {
            revert FeeIsTooSmall();
        }
        _feeState.deposit(msg.value);
        return true;
    }

    function processingFee() external view returns (uint256) {
        if (_feeState.processingFee == 0) {
            return FeeManagerLib.toDec(1) / 100;
        }
        return _feeState.processingFee;
    }

    function processingFeeDecimals() external pure returns (uint256) {
        return FeeManagerLib.decimals();
    }

    function _addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) internal {
        handlePayment();
        _requests.addRequest(callbackContract, callbackArgs, nonce, sender);
    }

    function addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool) {
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

        (bytes32 id, RequestLib.RequestStats memory reqStats) = getRequestProps(
            callbackContract,
            callbackArgs,
            nonce,
            sender
        );

        // prevent duplicated request execution
        if (reqStats.status != RequestLib.RequestStatus.Pending) {
            revert InvalidRequestsExecution(id);
        }

        (, /* bytes32[3] reportContextData */ bytes memory reportData) = abi
            .decode(unverifiedReport, (bytes32[3], bytes));

        // Report verification fees
        IFeeManager feeManager = IFeeManager(address(verifier.s_feeManager()));

        (IAsset memory fee, , ) = feeManager.getFeeAndReward(
            address(this),
            reportData,
            feeManager.i_nativeAddress()
        );

        _feeState.updateFee(fee.amount);

        // Verify the report
        bytes memory verifiedReportData = verifier.verify{value: fee.amount}(
            unverifiedReport,
            abi.encode(fee.assetAddress)
        );

        _feeState.spend(fee.amount);

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

        _requests.fulfillRequest(id);
    }

    function fallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external nonReentrant returns (bool) {
        (bytes32 id, bool executable, uint256 reward) = previewFallbackCall(
            callbackContract,
            callbackArgs,
            nonce,
            sender
        );

        if (!executable) {
            revert InvalidRequestsExecution(id);
        }

        (, int256 price, , , ) = priceFeed.latestRoundData();

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

        (bool rewardingSuccess, ) = payable(msg.sender).call{value: reward}("");

        if (!rewardingSuccess) {
            revert FailedRequestsConsumption(id);
        }

        _requests.fulfillRequest(id);

        _feeState.spendReward();

        return true;
    }

    function previewFallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) public view returns (bytes32, bool, uint256) {
        (bytes32 id, RequestLib.RequestStats memory reqStats) = getRequestProps(
            callbackContract,
            callbackArgs,
            nonce,
            sender
        );

        bool executable = reqStats.status == RequestLib.RequestStatus.Pending &&
            reqStats.blockNumber + requestTimeout <= block.number;

        return (id, executable, _feeState.reward());
    }

    // Utils

    function getRequestProps(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) public view returns (bytes32, RequestLib.RequestStats memory) {
        bytes32 id = RequestLib.generateId(
            callbackContract,
            callbackArgs,
            nonce,
            sender
        );

        return (id, _requests.getRequest(id));
    }

    // fallbacks

    fallback() external payable {
        handlePayment();
    }

    receive() external payable {
        handlePayment();
    }
}
