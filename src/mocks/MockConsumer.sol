// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Request} from "src/interfaces/Request.sol";
import {IOracle} from "src/interfaces/IOracle.sol";
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

    event AutomationTrigger(Request request);
    event FakeAutomationTrigger(Request request);

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

    function addRequest(
        CustomRequestParams memory params
    ) private returns (Request memory request) {
        request = Request({
            callBackContract: address(this),
            callBackArgs: abi.encode(params)
        });
        bool success = IOracle(oracle).addRequest(request);
        if (!success) {
            revert UnsuccesfullTrigger();
        }
    }

    function trigger(CustomRequestParams memory params) public returns (bool) {
        emit AutomationTrigger(addRequest(params));
        return true;
    }

    function triggerFake(
        CustomRequestParams memory params
    ) public returns (bool) {
        emit FakeAutomationTrigger(addRequest(params));
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
