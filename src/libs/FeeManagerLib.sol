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

    function premiumCoeff() public pure returns (uint256) {
        return toDec(1) / 10;
    }

    function calcCurrentFee(uint256 number) public pure returns (uint256) {
        return number * (toDec(1) + premiumCoeff());
    }

    function calcPremium(uint256 number) public pure returns (uint256) {
        return number * premiumCoeff();
    }

    function updateFee(
        FeeState memory feeState,
        uint256 lastReportFee
    ) external pure {
        uint256 currentFee = calcCurrentFee(lastReportFee);
        feeState.processingFee =
            ((feeState.processingFee * 35) / 100 + (currentFee * 65) / 100) /
            2;
    }

    function spend(FeeState memory feeState, uint256 value) external pure {
        feeState.treasure -= value;
    }

    function spendReward(FeeState memory feeState) external pure {
        feeState.treasure -= reward(feeState);
    }

    function deposit(FeeState memory feeState, uint256 value) external pure {
        feeState.treasure += value;
        feeState.premium += calcPremium(value);
    }

    function reward(FeeState memory feeState) public pure returns (uint256) {
        return feeState.processingFee + calcPremium(feeState.premium);
    }
}
