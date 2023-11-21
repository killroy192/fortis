// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

contract Test {
    address public adr;
    address public adr2;

    constructor(address _adr, address _adr2) {
        adr = _adr;
        adr2 = _adr2;
    }

    function hello() external pure returns (bool) {
        return true;
    }
}
