// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IVerifierProxy {
    function verify(
        bytes memory signedReport
    ) external payable returns (bytes memory verifierResponse);
}
