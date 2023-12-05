// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console

import "@std/Test.sol";

import {FeeLib} from "src/libs/FeeLib.sol";

contract FeeLibTest is Test {
    function test_decimals() public {
        assertEq(FeeLib.decimals(), 18);
    }

    function test_toDec() public {
        assertEq(FeeLib.toDec(1), 1 * 10 ** 18);
    }

    function test_fromDec() public {
        assertEq(FeeLib.fromDec(FeeLib.toDec(1)), 1);
    }

    function test_insuranceCoeff() public {
        assertEq(FeeLib.insuranceCoeff(), 1 * 10 ** 17);
    }

    function test_calcFee() public {
        assertEq(FeeLib.calcFee(10), 11);
    }
}
