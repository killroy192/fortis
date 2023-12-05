// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {RequestLib} from "../libs/RequestLib.sol";

interface IOracle {
    struct UpKeepMeta {
        uint256 id;
        bool approved;
        address creator;
    }

    function onRegister(uint256 id) external;

    function addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool);

    function fallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool);

    function previewFallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external view returns (bytes32, bool, uint256);

    function onTokenTransfer(
        address sender,
        uint256 amount,
        uint256 id
    ) external returns (bool);

    function onTokenTransferPreview(
        address token,
        uint256 amount,
        uint256 id
    ) external view returns (bool, uint256);
}
