// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IVerifierFeeManager} from "./IVerifierFeeManager.sol";

// Custom interfaces for IVerifierProxy and IFeeManager
interface IVerifierProxy {
    function verify(
        bytes calldata payload,
        bytes calldata parameterPayload
    ) external payable returns (bytes memory verifierResponse);

    function s_feeManager() external view returns (IVerifierFeeManager);
}
