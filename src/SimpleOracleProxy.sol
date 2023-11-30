// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

// solhint-disable-next-line max-line-length
import {StreamsLookupCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/StreamsLookupCompatibleInterface.sol";
import {ILogAutomation, Log} from "@chainlink/contracts/src/v0.8/automation/interfaces/ILogAutomation.sol";
import {Ownable} from "src/vendor/@openzeppelin/contracts/access/Ownable.sol";
import {IOracle} from "./interfaces/IOracle.sol";

contract SimpleOracleProxy is
    Ownable,
    IOracle,
    ILogAutomation,
    StreamsLookupCompatibleInterface
{
    address private implementation;

    constructor(address _implementation) Ownable(msg.sender) {
        implementation = _implementation;
    }

    function upgrade(address _implementation) external onlyOwner {
        implementation = _implementation;
    }

    function currentImplementation() external view returns (address) {
        return implementation;
    }

    function checkLog(
        Log calldata log,
        bytes memory checkData
    ) external returns (bool, bytes memory) {
        return ILogAutomation(implementation).checkLog(log, checkData);
    }

    function checkCallback(
        bytes[] calldata values,
        bytes calldata extraData
    ) external view returns (bool, bytes memory) {
        return
            StreamsLookupCompatibleInterface(implementation).checkCallback(
                values,
                extraData
            );
    }

    function performUpkeep(bytes calldata performData) external {
        ILogAutomation(implementation).performUpkeep(performData);
    }

    function addRequest(
        address callbackContract,
        bytes memory callbackArgs
    ) external returns (bool) {
        return
            IOracle(implementation).addRequest(callbackContract, callbackArgs);
    }

    fallback() external payable {}
}
