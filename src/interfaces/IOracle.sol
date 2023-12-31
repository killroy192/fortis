// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IOracle {
    event SetOracleId(uint256 id);

    struct UpKeepMeta {
        uint256 id;
        bool approved;
        address creator;
    }

    function onRegister(uint256 id) external;

    function addRequest(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool);

    function fallbackCall(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool);

    function previewFallbackCall(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external view returns (bytes32, bool, uint256);

    function swap(uint256 amount) external returns (bool);

    function swapPreview(uint256 amount) external view returns (bool, uint256);
}
