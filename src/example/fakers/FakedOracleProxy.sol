// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {StreamsLookupCompatibleInterface} from
    "@chainlink/contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {
    ILogAutomation,
    Log
} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IFakedOracle} from "./IFakedOracle.sol";

/*
 * Contract for dev porposes
 * @note keeper fundint won't work when OracleRouter is used
 */
contract FakedOracleProxy is
    Ownable,
    IFakedOracle,
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

    function checkLog(Log calldata log, bytes memory checkData)
        external
        returns (bool, bytes memory)
    {
        return ILogAutomation(_implementation).checkLog(log, checkData);
    }

    function checkCallback(bytes[] calldata values, bytes calldata extraData)
        external
        view
        returns (bool, bytes memory)
    {
        return StreamsLookupCompatibleInterface(_implementation).checkCallback(values, extraData);
    }

    function performUpkeep(bytes calldata performData) external {
        ILogAutomation(_implementation).performUpkeep(performData);
    }

    function fallbackCall(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool) {
        return IFakedOracle(_implementation).fallbackCall(
            callbackContract, callbackArgs, nonce, sender
        );
    }

    function previewFallbackCall(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) public view returns (bytes32, bool, uint256) {
        return IFakedOracle(_implementation).previewFallbackCall(
            callbackContract, callbackArgs, nonce, sender
        );
    }

    function addRequest(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool) {
        return IFakedOracle(_implementation).addRequest{value: msg.value}(
            callbackContract, callbackArgs, nonce, sender
        );
    }

    function addFakeRequest(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool) {
        return IFakedOracle(_implementation).addFakeRequest{value: msg.value}(
            callbackContract, callbackArgs, nonce, sender
        );
    }

    function onRegister(uint256 id) external {
        return IFakedOracle(_implementation).onRegister(id);
    }

    function swap(address sender, uint256 amount) external returns (bool) {
        return IFakedOracle(_implementation).swap(sender, amount);
    }

    function swapPreview(uint256 amount) external view returns (bool, uint256) {
        return IFakedOracle(_implementation).swapPreview(amount);
    }

    // solhint-disable-next-line no-complex-fallback
    fallback() external payable {
        (bool sent,) = _implementation.call{value: msg.value}(msg.data);
        require(sent, "Failed to fallback");
    }

    receive() external payable {
        (bool sent,) = _implementation.call{value: msg.value}("");
        require(sent, "Failed to fallback");
    }
}
