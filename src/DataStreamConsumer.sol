// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {StreamsLookupCompatibleInterface} from
    "@chainlink/contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {
    ILogAutomation,
    Log
} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";

abstract contract DataStreamConsumer is ILogAutomation, StreamsLookupCompatibleInterface {
    string[] internal feedIds;

    string public constant DATASTREAMS_FEEDLABEL = "feedIDs";
    string public constant DATASTREAMS_QUERYLABEL = "timestamp";

    // Find a complete list of IDs and verifiers at https://docs.chain.link/data-streams/stream-ids
    constructor(string memory _feedId) {
        feedIds.push(_feedId);
    }

    function checkLog(Log calldata log, bytes memory) external view returns (bool, bytes memory) {
        revert StreamsLookup(
            DATASTREAMS_FEEDLABEL, feedIds, DATASTREAMS_QUERYLABEL, log.timestamp, log.data
        );
    }

    function checkCallback(bytes[] calldata values, bytes calldata extraData)
        external
        pure
        returns (bool, bytes memory)
    {
        return (true, abi.encode(values, extraData));
    }

    function performUpkeep(bytes calldata performData) external virtual;
}
