// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {OracleRouter} from "src/OracleRouter.sol";
import {IFakeOracle} from "src/interfaces/IFakeOracle.sol";

/*
 * Contract for dev porposes
 * @note keeper fundint won't work when OracleRouter is used
 */
contract MockOracleRouter is OracleRouter, IFakeOracle {
    // solhint-disable-next-line no-empty-blocks
    constructor() OracleRouter() {}

    function addFakeRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool) {
        return
            IFakeOracle(implementation()).addFakeRequest(
                callbackContract,
                callbackArgs,
                nonce,
                sender
            );
    }
}
