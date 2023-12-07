// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {IAsset} from "../interfaces/IAsset.sol";
import {IFeeManager} from "../interfaces/IFeeManager.sol";
import {IVerifierProxy} from "../interfaces/IVerifierProxy.sol";
import {BasicReport} from "../interfaces/BasicReport.sol";

library VerifierLib {
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
