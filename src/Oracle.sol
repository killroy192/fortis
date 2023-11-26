// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Common} from "@chainlink/contracts/src/v0.8/libraries/Common.sol";
import {Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";

import {IRewardManager} from "@chainlink/contracts/src/v0.8/llo-feeds/interfaces/IRewardManager.sol";

import {Request} from "./interfaces/Request.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";
import {IFeeManager} from "./interfaces/IFeeManager.sol";
import {IEmitter} from "./interfaces/IEmitter.sol";
import {IOracleConsumerContract, ForwardData, FeedType} from "./interfaces/IOracleCallBackContract.sol";
import {IRequestsManager} from "./interfaces/IRequestsManager.sol";

import {RequestLib} from "./libs/RequestLib.sol";

import {DataStreamConsumer} from "./DataStreamConsumer.sol";
import {PriceFeedConsumer} from "./PriceFeedConsumer.sol";
import {RequestsManager} from "./RequestsManager.sol";

contract Oracle is IEmitter, DataStreamConsumer, PriceFeedConsumer {
    using RequestLib for Request;

    error InvalidRequestsExecution(bytes32 id);

    IVerifierProxy public immutable verifier;
    RequestsManager public immutable requestManager;
    // blocks from request initialization
    uint256 public immutable requestTimeout;

    // Find a complete list of IDs and verifiers at https://docs.chain.link/data-streams/stream-ids
    constructor(
        address _verifier,
        string memory _dataStreamfeedId,
        address _priceFeedId,
        uint256 _requestTimeout
    ) DataStreamConsumer(_dataStreamfeedId) PriceFeedConsumer(_priceFeedId) {
        verifier = IVerifierProxy(_verifier);
        requestManager = new RequestsManager();
        requestTimeout = _requestTimeout;
    }

    function emitRequest(Request memory request) external {
        bytes32 id = request.generateId();
        requestManager.addRequest(id);
        emit AutomationTrigger(id);
    }

    function verifyAndCall(
        bytes memory unverifiedReport,
        bytes memory extraData
    ) internal override {
        (address callBackContract, bytes memory callBackArgs) = abi.decode(
            extraData,
            (address, bytes)
        );

        (
            bytes32 id,
            IRequestsManager.RequestStats memory reqStats
        ) = getRequestProps(
                Request({
                    callBackContract: callBackContract,
                    callBackArgs: callBackArgs
                })
            );
        // prevent duplicated request execution
        if (reqStats.status == IRequestsManager.RequestStatus.Pending) {
            revert InvalidRequestsExecution(id);
        }

        (, /* bytes32[3] reportContextData */ bytes memory reportData) = abi
            .decode(unverifiedReport, (bytes32[3], bytes));

        IFeeManager feeManager = IFeeManager(address(verifier.s_feeManager()));
        IRewardManager rewardManager = IRewardManager(
            address(feeManager.i_rewardManager())
        );

        address feeTokenAddress = feeManager.i_linkAddress();
        (Common.Asset memory fee, , ) = feeManager.getFeeAndReward(
            address(this),
            reportData,
            feeTokenAddress
        );

        // Approve rewardManager to spend this contract's balance in fees
        IERC20(feeTokenAddress).approve(address(rewardManager), fee.amount);

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

        IOracleConsumerContract(callBackContract).consume(
            ForwardData({
                price: int256(int192(report.price)),
                feedType: FeedType.DataStream,
                forwardArguments: callBackArgs
            })
        );

        requestManager.fulfillRequest(id);
    }

    function fallbackCall(Request memory request) external {
        (
            bytes32 id,
            IRequestsManager.RequestStats memory reqStats
        ) = getRequestProps(request);

        if (
            reqStats.status != IRequestsManager.RequestStatus.Pending ||
            reqStats.blockNumber + requestTimeout < block.number
        ) {
            revert InvalidRequestsExecution(id);
        }

        int256 price = getLatestPrice();

        IOracleConsumerContract(request.callBackContract).consume(
            ForwardData({
                price: price,
                feedType: FeedType.PriceFeed,
                forwardArguments: request.callBackArgs
            })
        );
        requestManager.fulfillRequest(id);
    }

    // Utils

    function getRequestProps(
        Request memory request
    ) public view returns (bytes32, RequestsManager.RequestStats memory) {
        bytes32 id = request.generateId();

        return (id, requestManager.getRequest(id));
    }

    fallback() external payable {}
}
