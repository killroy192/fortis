// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {Request} from "./Request.sol";

interface IOracle {
    function addRequest(
        address callbackContract,
        bytes memory callbackArgs
    ) external returns (bool);
}
