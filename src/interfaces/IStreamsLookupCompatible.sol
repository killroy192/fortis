// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IStreamsLookupCompatible {
    error StreamsLookup(
        string feedParamKey,
        string[] feeds,
        string timeParamKey,
        uint256 time,
        bytes extraData
    );

    function checkCallback(
        bytes[] memory values,
        bytes memory extraData
    ) external view returns (bool upkeepNeeded, bytes memory performData);
}
