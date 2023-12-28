// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IOracle} from "src/interfaces/IOracle.sol";
import {IOracleConsumerContract, ForwardData} from "src/interfaces/IOracleCallBackContract.sol";
import {IFakedOracle} from "./fakers/IFakedOracle.sol";

/**
 * @title SwapApp
 */
contract SwapApp is IOracleConsumerContract {
    error UnsuccesfullTradeInititation(TradeParamsStruct tradeParams, uint256 nonce);
    error NoAccess(address initiator);
    error FailedSwap(address tokenIn, uint256 amountIn, address tokenOut, uint256 outputAmount);

    event Price(uint256 price);

    address public immutable ORACLE;

    struct TradeParamsStruct {
        address recipient;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
    }

    event TradeExecuted(uint256 tokensAmount, int256 price);

    constructor(address _oracle) {
        ORACLE = _oracle;
    }

    modifier oracleCallback() {
        if (msg.sender != ORACLE) {
            revert NoAccess(msg.sender);
        }
        _;
    }

    function trade(TradeParamsStruct calldata tradeParams, uint256 nonce)
        external
        payable
        returns (bool)
    {
        bool success = IOracle(ORACLE).addRequest{value: msg.value}(
            address(this), abi.encode(tradeParams), nonce, msg.sender
        );
        if (!success) {
            revert UnsuccesfullTradeInititation(tradeParams, nonce);
        }
        return success;
    }

    function notAutomatedTrade(TradeParamsStruct calldata tradeParams, uint256 nonce)
        external
        payable
        returns (bool)
    {
        bool success = IFakedOracle(ORACLE).addFakeRequest{value: msg.value}(
            address(this), abi.encode(tradeParams), nonce, msg.sender
        );
        if (!success) {
            revert UnsuccesfullTradeInititation(tradeParams, nonce);
        }
        return success;
    }

    function consume(ForwardData calldata forwardData) external oracleCallback returns (bool) {
        TradeParamsStruct memory tradeParams =
            abi.decode(forwardData.forwardArguments, (TradeParamsStruct));
        uint256 successfullyTradedTokens = _swapTokens(forwardData.price, tradeParams);
        emit TradeExecuted(successfullyTradedTokens, forwardData.price);
        return true;
    }

    //swap logic

    function _scalePriceToTokenDecimals(address tokenOut, int256 priceFromReport)
        private
        view
        returns (uint256)
    {
        uint8 pricefeedDecimals = 18;
        uint8 tokenOutDecimals = IERC20Metadata(tokenOut).decimals();
        if (tokenOutDecimals < pricefeedDecimals) {
            uint8 difference = pricefeedDecimals - tokenOutDecimals;
            return uint256(priceFromReport) / 10 ** difference;
        }

        if (tokenOutDecimals > pricefeedDecimals) {
            uint256 difference = tokenOutDecimals - pricefeedDecimals;
            return uint256(priceFromReport) * 10 ** difference;
        }

        return uint256(priceFromReport);
    }

    function _swapTokens(int256 price, TradeParamsStruct memory tradeParams)
        private
        returns (uint256)
    {
        uint8 inputTokenDecimals = IERC20Metadata(tradeParams.tokenIn).decimals();
        uint256 priceForOneToken = _scalePriceToTokenDecimals(tradeParams.tokenOut, price);

        emit Price(priceForOneToken);

        uint256 outputAmount = (priceForOneToken * tradeParams.amountIn) / 10 ** inputTokenDecimals;

        bool successCharge = IERC20Metadata(tradeParams.tokenIn).transferFrom(
            tradeParams.recipient, address(this), tradeParams.amountIn
        );

        bool successPay =
            IERC20Metadata(tradeParams.tokenOut).transfer(tradeParams.recipient, outputAmount);

        if (!successCharge || !successPay) {
            revert FailedSwap(
                tradeParams.tokenIn, tradeParams.amountIn, tradeParams.tokenOut, outputAmount
            );
        }

        return outputAmount;
    }

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
