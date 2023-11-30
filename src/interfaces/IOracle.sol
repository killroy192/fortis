// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IOracle {
    function addRequest(
        address callbackContract,
        bytes memory callbackArgs
    ) external returns (bool);
}
