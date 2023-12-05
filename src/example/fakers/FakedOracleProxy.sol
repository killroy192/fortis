// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {OracleRouter} from "src/OracleRouter.sol";
import {IFakedOracle} from "./IFakedOracle.sol";

/*
 * Contract for dev porposes
 * @note keeper fundint won't work when OracleRouter is used
 */
contract FakedOracleProxy is OracleRouter, IFakedOracle {
    // solhint-disable-next-line no-empty-blocks
    constructor() OracleRouter() {}

    function addFakeRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool) {
        return
            IFakedOracle(implementation()).addFakeRequest{value: msg.value}(
                callbackContract,
                callbackArgs,
                nonce,
                sender
            );
    }
}
