// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// solhint-disable-next-line max-line-length
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";

abstract contract DataStreamConsumer is
    ILogAutomation,
    StreamsLookupCompatibleInterface
{
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
    ) external view returns (bool upkeepNeeded, bytes memory performData) {
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
    function performUpkeep(bytes calldata performData) external {
        // Decode the performData bytes passed in by CL Automation.
        // This contains the data returned by your implementation in checkCallback().
        (bytes[] memory signedReports, bytes memory extraData) = abi.decode(
            performData,
            (bytes[], bytes)
        );

        bytes memory unverifiedReport = signedReports[0];

        bytes32 requestId = keccak256(extraData);

        onPerformUpkeep(unverifiedReport, extraData, requestId);
    }

    function onPerformUpkeep(
        bytes memory unverifiedReport,
        bytes memory extraData,
        bytes32 id
    ) internal virtual;
}
