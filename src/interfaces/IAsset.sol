// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

/*
 * Asset Struct is copy pasted from "@chainlink/contracts/src/v0.8/libraries/Common.sol"
 * But with increased version
 */

struct IAsset {
    address assetAddress;
    uint256 amount;
}
