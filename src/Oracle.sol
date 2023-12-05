// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {LinkTokenInterface} from "@chainlink/contracts/src/v0.8/shared/interfaces/LinkTokenInterface.sol";
import {SafeCast} from "@openzeppelin/contracts/utils/math/SafeCast.sol";

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";
import {IOracle} from "./interfaces/IOracle.sol";
import {IOracleConsumerContract, ForwardData, FeedType} from "./interfaces/IOracleCallBackContract.sol";
import {IAutomationEmitter} from "./interfaces/IAutomationEmitter.sol";
import {IAutomationRegistry} from "./interfaces/IAutomationRegistry.sol";

import {RequestLib} from "./libs/RequestLib.sol";
import {FeeLib} from "./libs/FeeLib.sol";
import {VerifierLib} from "./libs/VerifierLib.sol";

import {DataStreamConsumer} from "./DataStreamConsumer.sol";

contract Oracle is IOracle, DataStreamConsumer, ReentrancyGuard {
    error InvalidRequestsExecution(bytes32 id);
    error FailedRequestsConsumption(bytes32 id);
    error FeeIsTooSmall(bytes32 id);
    error NonZeroFeeRequired();
    error OnlyCallableByLINKToken();
    error InvalidKeeperId(uint256 id, uint256 expectedId);
    error InvalidTransferAmount(uint256 maxReward);
    error FailedLinkTransfer();
    error OnRegisterFailed(uint256 id, address sender);

    IAutomationEmitter public immutable emitter;

    IVerifierProxy public immutable verifier;
    using VerifierLib for IVerifierProxy;

    AggregatorV3Interface public immutable priceFeed;
    AggregatorV3Interface public immutable linkNativeFeed;

    LinkTokenInterface public immutable link;
    address public immutable registry;
    // blocks from request initialization
    uint256 public immutable requestTimeout;

    RequestLib.Requests private _requests;
    using RequestLib for RequestLib.Requests;

    UpKeepMeta private meta;

    modifier nonZeroPayment() {
        if (msg.value == 0) {
            revert NonZeroFeeRequired();
        }
        _;
    }

    constructor(
        address _emmiter,
        address _verifier,
        string memory _dataStreamfeedId,
        address _priceFeed,
        address _linkNativeFeed,
        address _linkToken,
        address _registry,
        uint256 _requestTimeout
    ) DataStreamConsumer(_dataStreamfeedId) {
        emitter = IAutomationEmitter(_emmiter);
        verifier = IVerifierProxy(_verifier);
        priceFeed = AggregatorV3Interface(_priceFeed);
        linkNativeFeed = AggregatorV3Interface(_linkNativeFeed);
        link = LinkTokenInterface(_linkToken);
        requestTimeout = _requestTimeout;
        registry = _registry;
        meta.creator = msg.sender;
    }

    function onRegister(uint256 id) external {
        if (meta.approved || msg.sender != meta.creator) {
            revert OnRegisterFailed(id, msg.sender);
        }
        meta.id = id;
        meta.approved = true;
        emit SetOracleId(id);
    }

    function _addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) internal {
        _requests.addRequest(callbackContract, callbackArgs, nonce, sender);
    }

    function addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external payable nonZeroPayment returns (bool) {
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
        uint256 initGas = gasleft();
        // Decode the performData bytes passed in by CL Automation.
        // This contains the data returned by your implementation in checkCallback().
        (bytes[] memory signedReports, bytes memory extraData) = abi.decode(
            performData,
            (bytes[], bytes)
        );

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

        VerifierLib.BasicReport memory report = verifier.verifyBasicReport(
            signedReports
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

        if (
            FeeLib.calcFee((initGas - gasleft()) * tx.gasprice) <
            reqStats.executionFee
        ) {
            revert FeeIsTooSmall(id);
        }
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

        return (id, executable, reqStats.executionFee);
    }

    /**
     * @notice uses LINK's transferAndCall to LINK and add funding to an upkeep
     */
    function swap(
        address sender,
        uint256 amount
    ) external nonReentrant returns (bool) {
        (bool doTransfer, uint256 reward) = swapPreview(amount);

        if (doTransfer) {
            bool success = link.transferFrom(sender, address(this), amount);

            if (!success) revert FailedLinkTransfer();

            link.approve(registry, amount);

            IAutomationRegistry(registry).addFunds(
                meta.id,
                SafeCast.toUint96(amount)
            );

            (bool rewardingSuccess, ) = payable(sender).call{value: reward}("");
            return rewardingSuccess;
        }
        return doTransfer;
    }

    function swapPreview(uint256 amount) public view returns (bool, uint256) {
        (, int256 linkPrice, , , ) = linkNativeFeed.latestRoundData();
        uint256 reward = FeeLib.fromDec(
            uint256(linkPrice) *
                FeeLib.fromDec(
                    amount * (FeeLib.toDec(1) + FeeLib.swapPremium())
                )
        );

        uint256 maxReward = address(this).balance / 5;

        return (maxReward >= reward, reward);
    }

    // Utils

    function getRequestProps(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) private view returns (bytes32, RequestLib.RequestStats memory) {
        bytes32 id = RequestLib.generateId(
            callbackContract,
            callbackArgs,
            nonce,
            sender
        );

        return (id, _requests.getRequest(id));
    }

    // fallbacks

    // solhint-disable-next-line no-empty-blocks
    fallback() external payable {}

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
