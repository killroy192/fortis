// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IOracle} from "src/interfaces/IOracle.sol";
import {IFakedOracle} from "./fakers/IFakedOracle.sol";
import {IOracleConsumerContract, FeedType, ForwardData} from "src/interfaces/IOracleCallBackContract.sol";

/**
 * @title SimpleConsumer
 * @notice Use this contract implements IOracleConsumerContract
 * interface with simple data forwarding logic.
 * Can be used as an example or for e2e/demo.
 */
contract SimpleConsumer is IOracleConsumerContract {
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

    CustomRequestParams private hardcodedRequestParams =
        CustomRequestParams({
            tokenIn: address(0),
            tokenOut: address(0),
            amountIn: 100
        });

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function trigger(
        CustomRequestParams memory params,
        uint256 nonce
    ) public returns (bool) {
        bool success = IOracle(oracle).addRequest(
            address(this),
            abi.encode(params),
            nonce,
            msg.sender
        );
        if (!success) {
            revert UnsuccesfullTrigger();
        }
        return true;
    }

    function triggerFake(
        CustomRequestParams memory params,
        uint256 nonce
    ) public returns (bool) {
        bool success = IFakedOracle(oracle).addFakeRequest(
            address(this),
            abi.encode(params),
            nonce,
            msg.sender
        );
        if (!success) {
            revert UnsuccesfullTrigger();
        }
        return true;
    }

    function triggerHardcoded() external returns (bool) {
        return trigger(hardcodedRequestParams, block.number);
    }

    function triggerFakeHardcoded() external returns (bool) {
        return triggerFake(hardcodedRequestParams, block.number);
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
