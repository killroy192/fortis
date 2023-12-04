// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// solhint-disable-next-line max-line-length
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IOracle} from "./interfaces/IOracle.sol";

/*
 * Contract for dev porposes
 * @note keeper fundint won't work when OracleRouter is used
 */
contract OracleRouter is
    Ownable,
    IOracle,
    ILogAutomation,
    StreamsLookupCompatibleInterface
{
    address private _implementation;

    // solhint-disable-next-line no-empty-blocks
    constructor() Ownable(msg.sender) {}

    function upgradeTo(address implementation_) external onlyOwner {
        _implementation = implementation_;
    }

    function implementation() public view returns (address) {
        return _implementation;
    }

    function checkLog(
        Log calldata log,
        bytes memory checkData
    ) external returns (bool, bytes memory) {
        return ILogAutomation(_implementation).checkLog(log, checkData);
    }

    function checkCallback(
        bytes[] calldata values,
        bytes calldata extraData
    ) external view returns (bool, bytes memory) {
        return
            StreamsLookupCompatibleInterface(_implementation).checkCallback(
                values,
                extraData
            );
    }

    function performUpkeep(bytes calldata performData) external {
        ILogAutomation(_implementation).performUpkeep(performData);
    }

    function fallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool) {
        return
            IOracle(_implementation).fallbackCall(
                callbackContract,
                callbackArgs,
                nonce,
                sender
            );
    }

    function previewFallbackCall(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) public view returns (bytes32, bool, uint256) {
        return
            IOracle(_implementation).previewFallbackCall(
                callbackContract,
                callbackArgs,
                nonce,
                sender
            );
    }

    function addRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool) {
        return
            IOracle(_implementation).addRequest{value: msg.value}(
                callbackContract,
                callbackArgs,
                nonce,
                sender
            );
    }

    function handlePayment() public payable returns (bool) {
        return IOracle(_implementation).handlePayment{value: msg.value}();
    }

    function processingFee() external view returns (uint256) {
        return IOracle(_implementation).processingFee();
    }

    function processingFeeDecimals() external view returns (uint256) {
        return IOracle(_implementation).processingFeeDecimals();
    }

    fallback() external payable {
        handlePayment();
    }

    receive() external payable {
        handlePayment();
    }
}
