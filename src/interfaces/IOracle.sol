// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {Request} from "./Request.sol";

interface IOracle {
    function addRequest(Request memory request) external returns (bool);
}
