// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IOracle {
    function addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool);

    function fallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool);
}
