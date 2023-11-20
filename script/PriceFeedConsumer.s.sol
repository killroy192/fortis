// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import {Script} from "forge-std/Script.sol";
import {PriceFeedConsumer} from "../src/PriceFeedConsumer.sol";
import {HelperConfig} from "./HelperConfig.sol";
import {MockV3Aggregator} from "../src/test/mocks/MockV3Aggregator.sol";

contract DeployPriceFeedConsumer is Script, HelperConfig {
    uint8 public constant DECIMALS = 18;
    int256 public constant INITIAL_ANSWER = 2000e18;

    function run() external {
        HelperConfig helperConfig = new HelperConfig();

        (, , , , , address priceFeed, , , ) = helperConfig
            .activeNetworkConfig();

        if (priceFeed == address(0)) {
            priceFeed = address(new MockV3Aggregator(DECIMALS, INITIAL_ANSWER));
        }

        vm.startBroadcast();

        new PriceFeedConsumer(priceFeed);

        vm.stopBroadcast();
    }
}
