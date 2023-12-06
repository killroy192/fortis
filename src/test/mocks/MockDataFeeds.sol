// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-empty-blocks

import {MockETHLINKAggregator} from "@chainlink/contracts/src/v0.8/tests/MockETHLINKAggregator.sol";
import {MockV3Aggregator} from "@chainlink/contracts/src/v0.8/tests/MockV3Aggregator.sol";

contract MockLinkDataFeed is MockETHLINKAggregator {
    constructor() MockETHLINKAggregator(6 * 10 ** 14) {}
}

contract MockUSDDataFeed is MockV3Aggregator {
    constructor() MockV3Aggregator(8, 228173129000) {}
}
