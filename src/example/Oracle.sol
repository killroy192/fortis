// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Common} from "@chainlink/contracts/src/v0.8/libraries/Common.sol";
// solhint-disable-next-line max-line-length
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {IRewardManager} from "@chainlink/contracts/src/v0.8/llo-feeds/interfaces/IRewardManager.sol";
import {IERC20} from "./interfaces/IERC20.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";
import {IFeeManager} from "./interfaces/IFeeManager.sol";
import {DataStreamConsumer} from "./DataStreamConsumer.sol";
import {SafeDataStream} from "../SafeDataStream.sol";
import {PriceFeedConsumer} from "./PriceFeedConsumer.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE FOR DEMONSTRATION PURPOSES.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract Oracle is DataStreamConsumer, SafeDataStream, PriceFeedConsumer {
    struct BasicReport {
        // The feed ID the report has data for
        bytes32 feedId;
        // Earliest timestamp for which price is applicable
        uint32 validFromTimestamp;
        // Latest timestamp for which price is applicable
        uint32 observationsTimestamp;
        // Base cost to validate a transaction using the report, denominated in the chain’s native token (WETH/ETH)
        uint192 nativeFee;
        // Base cost to validate a transaction using the report, denominated in LINK
        uint192 linkFee;
        // Latest timestamp where the report can be verified on-chain
        uint32 expiresAt;
        // DON consensus median price, carried to 8 decimal places
        int192 price;
    }

    IVerifierProxy public immutable verifier;

    string public constant DATASTREAMS_FEEDLABEL = "feedIDs";
    string public constant DATASTREAMS_QUERYLABEL = "timestamp";

    // Find a complete list of IDs and verifiers at https://docs.chain.link/data-streams/stream-ids
    constructor(
        address _verifier,
        string _dataStreamfeedId,
        address _priceFeedId
    ) DataStreamConsumer(_dataStreamfeedId) PriceFeedConsumer(_priceFeedId) {
        verifier = IVerifierProxy(_verifier);
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
        BasicReport report = abi.decode(verifiedReportData, (BasicReport));

        fulfillRequest(id);
    }

    function executionFallback(
        bytes32 id
    ) external fallbackExecutionAllowed(id) {
        getLatestPrice();
        fulfillRequest(id);
    }

    fallback() external payable {}
}
