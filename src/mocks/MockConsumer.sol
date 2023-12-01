// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IOracle} from "src/interfaces/IOracle.sol";
import {IFakeOracle} from "src/interfaces/IFakeOracle.sol";
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
        uint256 nonce;
        address sender;
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
            amountIn: 100,
            nonce: 0,
            sender: address(0)
        });

    constructor(address _oracle) {
        oracle = _oracle;
    }

    function trigger(CustomRequestParams memory params) public returns (bool) {
        bool success = IOracle(oracle).addRequest(
            address(this),
            abi.encode(params),
            params.nonce,
            params.sender
        );
        if (!success) {
            revert UnsuccesfullTrigger();
        }
        return true;
    }

    function triggerFake(
        CustomRequestParams memory params
    ) public returns (bool) {
        bool success = IFakeOracle(oracle).addFakeRequest(
            address(this),
            abi.encode(params),
            params.nonce,
            params.sender
        );
        if (!success) {
            revert UnsuccesfullTrigger();
        }
        return true;
    }

    function triggerHardcoded() external returns (bool) {
        return trigger(hardcodedRequestParams);
    }

    function triggerFakeHardcoded() external returns (bool) {
        return triggerFake(hardcodedRequestParams);
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
