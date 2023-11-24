// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title The PriceConsumerV3 contract
 * @notice Returns latest price from Chainlink Price Feeds
 */
contract PriceFeedConsumer {
    AggregatorV3Interface internal immutable PRICE_FEED;

    constructor(address _priceFeed) {
        PRICE_FEED = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Returns the latest price
     *
     * @return latest price
     */
    function getLatestPrice() internal view returns (int256) {
        (
            ,
            /* uint80 roundID */
            int256 price /* uint256 startedAt */ /* uint256 timeStamp */,
            ,
            ,

        ) = PRICE_FEED.latestRoundData(); /* uint80 answeredInRound */
        return price;
    }
}
