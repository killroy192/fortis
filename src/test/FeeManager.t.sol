// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console

import "@std/Test.sol";

import {FeeManagerLib} from "src/libs/FeeManagerLib.sol";

contract FeeManagerLibTest is Test {
    using FeeManagerLib for FeeManagerLib.FeeState;
    FeeManagerLib.FeeState private feeState;

    function setUp() public {
        feeState.premium = 0;
        feeState.processingFee = 0;
        feeState.treasure = 0;
    }

    function test_decimals() public {
        assertEq(FeeManagerLib.decimals(), 18);
    }

    function test_toDec() public {
        assertEq(FeeManagerLib.toDec(1), 1 * 10 ** 18);
    }

    function test_fromDec() public {
        assertEq(FeeManagerLib.fromDec(FeeManagerLib.toDec(1)), 1);
    }

    function test_premiumCoeff() public {
        assertEq(FeeManagerLib.premiumCoeff(), 1 * 10 ** 17);
    }

    function test_calcFee() public {
        assertEq(FeeManagerLib.calcFee(10), 11);
    }

    function test_calcPremium() public {
        assertEq(FeeManagerLib.calcPremium(10), 1);
    }

    function test_deposit() public {
        uint256 deposit = FeeManagerLib.toDec(10);
        feeState.deposit(deposit);
        assertEq(feeState.treasure, deposit);
    }

    function test_updateFeeBasic() public {
        uint256 fee = (FeeManagerLib.toDec(1) / 1000);
        assertEq(feeState.processingFee, 0);
        feeState.updateFee(fee);
        assertEq(feeState.processingFee, FeeManagerLib.calcFee(fee));
    }

    function test_updateFeeEMA() public {
        uint256 fee = FeeManagerLib.toDec(1) / 1000;
        uint256 fee2 = FeeManagerLib.toDec(1) / 100;
        feeState.updateFee(fee);
        feeState.updateFee(fee2);
        assertEq(feeState.processingFee, FeeManagerLib.toDec(37675) / 10 ** 7);
    }

    function test_spend() public {
        uint256 deposit = FeeManagerLib.toDec(10);
        feeState.deposit(deposit);
        feeState.spend(deposit);
        assertEq(feeState.treasure, 0);
    }

    function test_reward() public {
        uint256 deposit = FeeManagerLib.toDec(10);
        feeState.deposit(deposit);
        uint256 fee = FeeManagerLib.toDec(1) / 100;
        feeState.updateFee(fee);

        assertEq(
            feeState.reward(),
            FeeManagerLib.calcPremium(FeeManagerLib.calcPremium(deposit)) +
                FeeManagerLib.calcFee(fee)
        );
    }

    function test_spendReward() public {
        uint256 deposit = FeeManagerLib.toDec(10);
        feeState.deposit(deposit);
        uint256 fee = FeeManagerLib.toDec(1) / 100;
        feeState.updateFee(fee);
        uint256 expectedTreasure = feeState.treasure - feeState.reward();
        feeState.spendReward();
        assertEq(feeState.treasure, expectedTreasure);
    }
}
