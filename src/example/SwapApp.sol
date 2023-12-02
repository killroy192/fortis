// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IOracle} from "src/interfaces/IOracle.sol";
import {IOracleConsumerContract, ForwardData} from "src/interfaces/IOracleCallBackContract.sol";
import {IFakedOracle} from "./fakers/IFakedOracle.sol";
import {ISwapRouter} from "./ISwapRouter.sol";

/**
 * @title SwapApp
 */
contract SwapApp is IOracleConsumerContract {
    uint24 public constant FEE = 3000;

    ISwapRouter public immutable i_router;
    address public immutable oracle;

    struct TradeParamsStruct {
        address recipient;
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        string feedId;
    }

    event TradeExecuted(uint256 tokensAmount);

    constructor(address _router, address _oracle) {
        i_router = ISwapRouter(_router);
        oracle = _oracle;
    }

    function trade(
        TradeParamsStruct memory tradeParams,
        uint256 nonce
    ) external {
        IOracle(oracle).addRequest(
            address(this),
            abi.encode(tradeParams),
            nonce,
            msg.sender
        );
    }

    function notAutomatedTrade(
        TradeParamsStruct memory tradeParams,
        uint256 nonce
    ) external {
        IFakedOracle(oracle).addFakeRequest(
            address(this),
            abi.encode(tradeParams),
            nonce,
            msg.sender
        );
    }

    function consume(ForwardData memory forwardData) external returns (bool) {
        TradeParamsStruct memory tradeParams = abi.decode(
            forwardData.forwardArguments,
            (TradeParamsStruct)
        );
        uint256 successfullyTradedTokens = _swapTokens(
            forwardData.price,
            tradeParams
        );
        emit TradeExecuted(successfullyTradedTokens);
        return true;
    }

    //swap logic

    function _scalePriceToTokenDecimals(
        IERC20Metadata tokenOut,
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
        uint8 inputTokenDecimals = IERC20Metadata(tradeParams.tokenIn)
            .decimals();
        uint256 priceForOneToken = _scalePriceToTokenDecimals(
            IERC20Metadata(tradeParams.tokenOut),
            price
        );

        uint256 outputAmount = (priceForOneToken * tradeParams.amountIn) /
            10 ** inputTokenDecimals;

        IERC20Metadata(tradeParams.tokenIn).transferFrom(
            tradeParams.recipient,
            address(this),
            tradeParams.amountIn
        );
        IERC20Metadata(tradeParams.tokenIn).approve(
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

    // solhint-disable-next-line no-empty-blocks
    receive() external payable {}
}
