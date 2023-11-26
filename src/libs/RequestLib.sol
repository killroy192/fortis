// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {Request} from "../interfaces/Request.sol";

library RequestLib {
    function generateId(
        Request memory request
    ) external pure returns (bytes32) {
        return keccak256(abi.encode(request));
    }
}
