// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Common} from "@chainlink/contracts/src/v0.8/libraries/Common.sol";
import {Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";

import {IRewardManager} from "@chainlink/contracts/src/v0.8/llo-feeds/interfaces/IRewardManager.sol";

import {IERC20} from "./interfaces/IERC20.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";
import {IFeeManager} from "./interfaces/IFeeManager.sol";
import {IEmitter} from "./interfaces/IEmitter.sol";
import {IOracleConsumerContract, ForwardData, FeedType} from "./interfaces/IOracleCallBackContract.sol";
import {IRequestsManager} from "./interfaces/IRequestsManager.sol";

import {DataStreamConsumer} from "./DataStreamConsumer.sol";
import {GaranteedExecution} from "./GaranteedExecution.sol";
import {PriceFeedConsumer} from "./PriceFeedConsumer.sol";
import {RequestsManager} from "./RequestsManager.sol";

contract Oracle is
    IEmitter,
    GaranteedExecution,
    DataStreamConsumer,
    PriceFeedConsumer
{
    IVerifierProxy public immutable verifier;
    RequestsManager public immutable requestManager;

    // Find a complete list of IDs and verifiers at https://docs.chain.link/data-streams/stream-ids
    constructor(
        address _verifier,
        string memory _dataStreamfeedId,
        address _priceFeedId,
        uint256 _requestTimeout
    )
        GaranteedExecution(_requestTimeout)
        DataStreamConsumer(_dataStreamfeedId)
        PriceFeedConsumer(_priceFeedId)
    {
        verifier = IVerifierProxy(_verifier);
        requestManager = new RequestsManager();
    }

    function emitRequest(GenericRequest memory request) external {
        bytes32 id = keccak256(abi.encode(request));
        addRequest(id);
        emit AutomationTrigger(id);
    }

    function onPerformUpkeep(
        bytes memory unverifiedReport,
        bytes memory extraData,
        bytes32 id
    ) internal override preventDuplicatedExecution(id) {
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

        mainExecution(report, extraData, id);
    }

    function mainExecution(
        BasicReport memory report,
        bytes memory extraData,
        bytes32 id
    ) private {
        (address callBackContract, bytes memory callBackArgs) = abi.decode(
            extraData,
            (address, bytes)
        );
        // solhint-disable-next-line avoid-low-level-calls
        IOracleConsumerContract(callBackContract).consume(
            ForwardData({
                price: int256(int192(report.price)),
                feedType: FeedType.DataStream,
                forwardArguments: callBackArgs
            })
        );
        fulfillRequest(id);
    }

    function executionFallback(
        GenericRequest memory request,
        bytes32 id
    ) external fallbackExecutionAllowed(id) {
        int256 price = getLatestPrice();
        // solhint-disable-next-line avoid-low-level-calls
        IOracleConsumerContract(request.callBackContract).consume(
            ForwardData({
                price: price,
                feedType: FeedType.PriceFeed,
                forwardArguments: request.callBackArgs
            })
        );
        fulfillRequest(id);
    }

    function addRequest(bytes32 _id) internal {
        requestManager.addRequest(_id);
    }

    function fulfillRequest(bytes32 _id) internal {
        requestManager.fulfillRequest(_id);
    }

    function getRequest(
        bytes32 _id
    ) public view override returns (IRequestsManager.Request memory) {
        return requestManager.getRequest(_id);
    }

    fallback() external payable {}
}
