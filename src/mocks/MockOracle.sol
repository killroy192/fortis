// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Oracle} from "src/Oracle.sol";
import {IFakeOracle} from "src/interfaces/IFakeOracle.sol";
import {IRequestsManager} from "src/interfaces/IRequestsManager.sol";

contract MockOracle is IFakeOracle, Oracle {
    event FakeAutomationTrigger(
        address callBackContract,
        bytes callBackArgs,
        uint256 nonce,
        address sender
    );

    // Find a complete list of IDs and verifiers at https://docs.chain.link/data-streams/stream-ids
    constructor(
        address _verifier,
        string memory _dataStreamfeedId,
        address _priceFeedId,
        uint256 _requestTimeout
    ) Oracle(_verifier, _dataStreamfeedId, _priceFeedId, _requestTimeout) {}

    function addFakeRequest(
        address callbackContract,
        bytes memory callbackArgs,
        uint256 nonce,
        address sender
    ) external returns (bool) {
        (
            bytes32 id,
            IRequestsManager.RequestStats memory reqStats
        ) = getRequestProps(callbackContract, callbackArgs, nonce, sender);
        // prevent duplicated request execution
        if (reqStats.status == IRequestsManager.RequestStatus.Fulfilled) {
            revert DuplicatedRequestCreation(id);
        }
        requestManager.addRequest(id);
        emit FakeAutomationTrigger(
            callbackContract,
            callbackArgs,
            nonce,
            sender
        );
        return true;
    }
}
