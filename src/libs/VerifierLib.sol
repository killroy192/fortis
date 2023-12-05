// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IAsset} from "../interfaces/IAsset.sol";
import {IFeeManager} from "../interfaces/IFeeManager.sol";
import {IVerifierProxy} from "../interfaces/IVerifierProxy.sol";

library VerifierLib {
    struct BasicReport {
        // The feed ID the report has data for
        bytes32 feedId;
        // Earliest timestamp for which price is applicable
        uint32 validFromTimestamp;
        // Latest timestamp for which price is applicable
        uint32 observationsTimestamp;
        // Base cost to validate a transaction using the report, denominated in the chain’s native token (WETH/ETH)
        uint192 nativeFee;
        // Base cost to validate a transaction using the report, denominated in LINK
        uint192 linkFee;
        // Latest timestamp where the report can be verified on-chain
        uint32 expiresAt;
        // DON consensus median price, carried to 8 decimal places
        int192 price;
    }

    function verifyBasicReport(
        IVerifierProxy verifier,
        bytes[] memory signedReports
    ) external returns (BasicReport memory) {
        (, /* bytes32[3] reportContextData */ bytes memory reportData) = abi
            .decode(signedReports[0], (bytes32[3], bytes));

        // Report verification fees
        IFeeManager feeManager = IFeeManager(address(verifier.s_feeManager()));

        (IAsset memory fee, , ) = feeManager.getFeeAndReward(
            address(this),
            reportData,
            feeManager.i_nativeAddress()
        );

        // Decode verified report data into BasicReport struct
        return
            abi.decode(
                verifier.verify{value: fee.amount}(
                    signedReports[0],
                    abi.encode(fee.assetAddress)
                ),
                (BasicReport)
            );
    }
}
