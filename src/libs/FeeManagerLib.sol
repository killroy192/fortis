// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

library FeeManagerLib {
    // TODO: implement events

    struct FeeState {
        uint256 processingFee;
        uint256 treasure;
        uint256 premium;
    }

    function decimals() public pure returns (uint8) {
        return 18;
    }

    function toDec(uint256 number) public pure returns (uint256) {
        return number * 10 ** decimals();
    }

    function fromDec(uint256 number) public pure returns (uint256) {
        return number / 10 ** decimals();
    }

    function premiumCoeff() public pure returns (uint256) {
        return toDec(1) / 10;
    }

    function calcFee(uint256 number) public pure returns (uint256) {
        return fromDec(number * (toDec(1) + premiumCoeff()));
    }

    function calcPremium(uint256 number) public pure returns (uint256) {
        return fromDec(number * premiumCoeff());
    }

    function deposit(FeeState storage feeState, uint256 value) external {
        feeState.treasure += value;
        feeState.premium += calcPremium(value);
    }

    function updateFee(
        FeeState storage feeState,
        uint256 lastReportFee
    ) external {
        uint256 fee = calcFee(lastReportFee);
        if (feeState.processingFee == 0) {
            feeState.processingFee = fee;
        } else {
            feeState.processingFee =
                ((feeState.processingFee * 35) / 100 + (fee * 65) / 100) /
                2;
        }
    }

    function spend(FeeState storage feeState, uint256 value) external {
        feeState.treasure -= value;
    }

    function reward(FeeState memory feeState) public pure returns (uint256) {
        return feeState.processingFee + calcPremium(feeState.premium);
    }

    function spendReward(FeeState storage feeState) external {
        feeState.treasure -= reward(feeState);
    }
}
