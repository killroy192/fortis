// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Request} from "src/interfaces/Request.sol";
import {IEmitter} from "src/interfaces/IEmitter.sol";
import {IOracleConsumerContract, FeedType, ForwardData} from "src/interfaces/IOracleCallBackContract.sol";

/**
 * @title MockConsumer
 * @notice Use this contract implements IOracleConsumerContract
 * interface with simple data forwarding logic.
 * Can be used as an example or for e2e/demo.
 */
contract MockConsumer is IOracleConsumerContract {
    struct CustomRequestParams {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
    }
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
