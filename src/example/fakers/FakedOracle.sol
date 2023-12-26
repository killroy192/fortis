// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Oracle} from "src/Oracle.sol";
import {IFakedOracle} from "./IFakedOracle.sol";

/**
 * @dev Faked oracle extends Oracle to make possible to emit 'fake' events.
 * Fake events do not handled by Chainlink Automation and emulates Chainlink Automation
 * anavailability
 */
contract FakedOracle is Oracle, IFakedOracle {
    event FakeAutomationTrigger(
        address callBackContract, bytes callBackArgs, uint256 nonce, address sender
    );

    constructor(
        address _emmiter,
        address _verifier,
        string memory _dataStreamfeedId,
        address _priceFeed,
        address _linkNativeFeed,
        address _linkToken,
        address _registry,
        uint256 _requestTimeout
    )
        Oracle(
            _emmiter,
            _verifier,
            _dataStreamfeedId,
            _priceFeed,
            _linkNativeFeed,
            _linkToken,
            _registry,
            _requestTimeout
        )
    // solhint-disable-next-line no-empty-blocks
    {}

    function addFakeRequest(
        address callbackContract,
        bytes calldata callbackArgs,
        uint256 nonce,
        address sender
    ) external payable returns (bool) {
        _addRequest(callbackContract, callbackArgs, nonce, sender);
        emit FakeAutomationTrigger(callbackContract, callbackArgs, nonce, sender);
        return true;
    }
}
