// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Request} from "src/interfaces/Request.sol";
import {IEmitter} from "src/interfaces/IEmitter.sol";
import {IMockEmitter} from "src/interfaces/IMockEmitter.sol";
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
    address public immutable oracle;

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function trigger(CustomRequestParams memory params) public returns (bool) {
        bool success = IEmitter(oracle).emitRequest(
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

    function triggerHardcoded() external returns (bool) {
        return
            trigger(
                CustomRequestParams({
                    tokenIn: address(0),
                    tokenOut: address(0),
                    amountIn: 100
                })
            );
    }

    function triggerFake(
        CustomRequestParams memory params
    ) public returns (bool) {
        bool success = IMockEmitter(oracle).emitFakeRequest(
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

    function triggerFakeHardcoded() external returns (bool) {
        return
            triggerFake(
                CustomRequestParams({
                    tokenIn: address(0),
                    tokenOut: address(0),
                    amountIn: 100
                })
            );
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
