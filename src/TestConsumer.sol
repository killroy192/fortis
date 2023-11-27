// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Request} from "./interfaces/Request.sol";
import {IEmitter} from "./interfaces/IEmitter.sol";
import {IOracleConsumerContract, FeedType, ForwardData} from "./interfaces/IOracleCallBackContract.sol";

struct CustomRequestParams {
    address tokenIn;
    address tokenOut;
    uint256 amountIn;
}

contract TestConsumer is IOracleConsumerContract {
    error UnsuccesfullTrigger();

    int256 public lastConsumedPrice;
    FeedType public lastConsumedFeedType;
    CustomRequestParams public lastConsumedForwardArguments;
    IEmitter public immutable oracle;

    constructor(address _oracle) {
        oracle = IEmitter(_oracle);
    }

    function trigger(
        CustomRequestParams memory params
    ) external returns (bool) {
        bool success = oracle.emitRequest(
            Request({
                callBackContract: address(this),
                callBackArgs: abi.encode(params)
            })
        );
        if (!success) {
            revert UnsuccesfullTrigger();
        }
        return true;
    }

    function consume(ForwardData memory forwardData) external returns (bool) {
        lastConsumedPrice = forwardData.price;
        lastConsumedFeedType = forwardData.feedType;
        lastConsumedForwardArguments = abi.decode(
            forwardData.forwardArguments,
            (CustomRequestParams)
        );
        return true;
    }
}
