// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {IOracle} from "src/interfaces/IOracle.sol";

interface IFakedOracle is IOracle {
    function addFakeRequest(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool);
}
