// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library FeeLib {
    function decimals() public pure returns (uint8) {
        return 18;
    }

    function toDec(uint256 number) public pure returns (uint256) {
        return number * 10 ** decimals();
    }

    function fromDec(uint256 number) public pure returns (uint256) {
        return number / 10 ** decimals();
    }

    function insuranceCoeff() public pure returns (uint256) {
        return toDec(10) / 100;
    }

    function swapPremium() public pure returns (uint256) {
        return toDec(5) / 100;
    }

    function calcFee(uint256 number) public pure returns (uint256) {
        return fromDec(number * (toDec(1) + insuranceCoeff()));
    }
}
