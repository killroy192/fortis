// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Oracle} from "src/Oracle.sol";
import {RequestLib} from "src/libs/RequestLib.sol";
import {Request} from "src/interfaces/Request.sol";

/**
 * @title MockOracle
 * @notice Based on the Oracle contract
 * @notice Use this contract when you need to test
 * ability to perform Oracle fallbackCall logic via
 * emitting non standart event.
 * Can be used as an example or for e2e/demo.
 */
contract MockOracle is Oracle {
    using RequestLib for Request;

    event FakeAutomationTrigger(Request request);

    Request private request;

    constructor(
        address _verifier,
        string memory _dataStreamfeedId,
        address _priceFeedId,
        uint256 _requestTimeout,
        address _hardcodedConsumer
    ) Oracle(_verifier, _dataStreamfeedId, _priceFeedId, _requestTimeout) {
        request = Request({
            callBackContract: _hardcodedConsumer,
            callBackArgs: ""
        });
    }

    function emitHardCodedFakeRequest() external returns (bool) {
        bytes32 id = request.generateId();
        requestManager.addRequest(id);
        emit FakeAutomationTrigger(request);
        return true;
    }

    function emitHardcodedRequest() external returns (bool) {
        bytes32 id = request.generateId();
        requestManager.addRequest(id);
        emit AutomationTrigger(request);
        return true;
    }
}
