// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

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
