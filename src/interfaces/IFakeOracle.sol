// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IFakeOracle {
    function addFakeRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool);
}
