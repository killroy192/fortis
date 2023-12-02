// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

enum FeedType {
    DataStream,
    PriceFeed
}

struct ForwardData {
    int256 price;
    FeedType feedType;
    bytes forwardArguments;
}

interface IOracleConsumerContract {
    function consume(ForwardData memory forwardData) external returns (bool);
}
