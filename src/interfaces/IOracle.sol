// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

interface IOracle {
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

    function handlePayment() external payable returns (bool);

    function processingFee() external view returns (uint256);

    function processingFeeDecimals() external view returns (uint256);
}
