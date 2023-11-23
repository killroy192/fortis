// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title The PriceConsumerV3 contract
 * @notice Acontract that returns latest price from Chainlink Price Feeds
 */
contract PriceFeedConsumer {
    // solhint-disable-next-line var-name-mixedcase
    AggregatorV3Interface internal immutable PRICE_FEED;

    constructor(address _priceFeed) {
        PRICE_FEED = AggregatorV3Interface(_priceFeed);
    }

    /**
     * @notice Returns the latest price
     *
     * @return latest price
     */
    function getLatestPrice() public view returns (int256) {
        (
            ,
            /* uint80 roundID */
            int256 price /* uint256 startedAt */ /* uint256 timeStamp */,
            ,
            ,

        ) = PRICE_FEED.latestRoundData(); /* uint80 answeredInRound */
        return price;
    }

    /**
     * @notice Returns the Price Feed address
     *
     * @return Price Feed address
     */
    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return PRICE_FEED;
    }
}
