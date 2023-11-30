// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// solhint-disable-next-line max-line-length
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";

abstract contract DataStreamConsumer is
    ILogAutomation,
    StreamsLookupCompatibleInterface
{
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

    struct Quote {
        address quoteAddress;
    }

    string[] private feedIds;

    string public constant DATASTREAMS_FEEDLABEL = "feedIDs";
    string public constant DATASTREAMS_QUERYLABEL = "timestamp";

    // Find a complete list of IDs and verifiers at https://docs.chain.link/data-streams/stream-ids
    constructor(string memory _feedId) {
        feedIds.push(_feedId);
    }

    // This function uses revert to convey call information.
    // See https://eips.ethereum.org/EIPS/eip-3668#rationale for details.
    function checkLog(
        Log calldata log,
        bytes memory
    ) external view returns (bool, bytes memory) {
        revert StreamsLookup(
            DATASTREAMS_FEEDLABEL,
            feedIds,
            DATASTREAMS_QUERYLABEL,
            log.timestamp,
            log.data
        );
    }

    // The Data Streams report bytes is passed here.
    // extraData is context data from feed lookup process.
    // Your contract may include logic to further process this data.
    // This method is intended only to be simulated off-chain by Automation.
    // The data returned will then be passed by Automation into performUpkeep
    function checkCallback(
        bytes[] calldata values,
        bytes calldata extraData
    ) external pure returns (bool, bytes memory) {
        return (true, abi.encode(values, extraData));
    }

    // function will be performed on-chain
    function performUpkeep(bytes calldata performData) external virtual;
}
