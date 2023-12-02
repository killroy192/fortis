// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IERC20} from "@uniswap/v2-core/contracts/interfaces/IERC20.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ISwapRouter} from "./interfaces/ISwapRouter.sol";
import {IVerifierProxy} from "./interfaces/IVerifierProxy.sol";
import "./IOracleCallBackContract.sol";

/**
 * @title DataStreamsConsumer
 * @dev This contract is a Chainlink Data Streams consumer.
 * This contract provides low-latency delivery of low-latency delivery of market data.
 * These reports can be verified onchain to verify their integrity.
 */
contract DataStreamsConsumer is IOracleConsumerContract {
    uint24 public constant FEE = 3000;

    ISwapRouter public i_router;
    IOracle public i_oracleEmitter;

    struct TradeParamsStruct {
        address recipient;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        string feedId;
    }

    event TradeExecuted(uint256 tokensAmount);

    function initializer(
        address router,
        address oracleEmitter
    ) public {
        i_router = ISwapRouter(router);
        i_oracleEmitter = IOracle(oracleEmitter);
    }

    function randomUINT() internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(
            tx.origin,
            blockhash(block.number - 1),
            block.timestamp
        )));
    }

    function trade(
        address tokenIn,
        address tokenOut,
        uint256 amount,
        string memory feedId,
        uint256 memory nonce
    ) external {
        i_oracleEmitter.addRequest(
            address(this),
            abi.encode(msg.sender, tokenIn, tokenOut, amount, feedId),
            nonce,
            msg.sender
        );
    }

    function consume(ForwardData memory forwardData) external returns (bool) {
        TradeParamsStruct memory tradeParams = abi.decode(forwardData.forwardArguments, (TradeParamsStruct));
        uint256 successfullyTradedTokens = _swapTokens(forwardData.price, tradeParams);
        emit TradeExecuted(successfullyTradedTokens);
        return true;
    }
    //swap logic

    function _scalePriceToTokenDecimals(
        IERC20 tokenOut,
        int256 priceFromReport
    ) private view returns (uint256) {
        uint256 pricefeedDecimals = 18;
        uint8 tokenOutDecimals = tokenOut.decimals();
        if (tokenOutDecimals < pricefeedDecimals) {
            uint256 difference = pricefeedDecimals - tokenOutDecimals;
            return uint256(priceFromReport) / 10 ** difference;
        } else {
            uint256 difference = tokenOutDecimals - pricefeedDecimals;
            return uint256(priceFromReport) * 10 ** difference;
        }
    }
    function _swapTokens(
        int256 price,
        TradeParamsStruct memory tradeParams
    ) private returns (uint256) {
        uint8 inputTokenDecimals = IERC20(tradeParams.tokenIn).decimals();
        uint256 priceForOneToken = _scalePriceToTokenDecimals(
            IERC20(tradeParams.tokenOut),
            price
        );

        uint256 outputAmount = (priceForOneToken * tradeParams.amountIn) /
            10 ** inputTokenDecimals;

        IERC20(tradeParams.tokenIn).transferFrom(
            tradeParams.recipient,
            address(this),
            tradeParams.amountIn
        );
        IERC20(tradeParams.tokenIn).approve(
            address(i_router),
            tradeParams.amountIn
        );

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams(
                tradeParams.tokenIn,
                tradeParams.tokenOut,
                FEE,
                tradeParams.recipient,
                tradeParams.amountIn,
                outputAmount,
                0
            );

        return i_router.exactInputSingle(params);
    }
    receive() external payable {}
}
