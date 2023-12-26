// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

import {IVerifierProxy} from "src/interfaces/IVerifierProxy.sol";
import {IVerifierFeeManager} from "src/interfaces/IVerifierFeeManager.sol";
import {IFeeManager} from "src/interfaces/IFeeManager.sol";
import {IAsset} from "src/interfaces/IAsset.sol";
import {BasicReport} from "src/interfaces/BasicReport.sol";

contract MockVerifierFeeManager is IVerifierFeeManager, IFeeManager {
    function getFeeAndReward(address, bytes memory, address)
        external
        pure
        returns (IAsset memory, IAsset memory, uint256)
    {
        return (
            IAsset({assetAddress: i_nativeAddress(), amount: 0}),
            IAsset({assetAddress: i_nativeAddress(), amount: 0}),
            0
        );
    }

    function i_linkAddress() external pure returns (address) {
        return address(100);
    }

    function i_nativeAddress() public pure returns (address) {
        return address(200);
    }

    function i_rewardManager() external pure returns (address) {
        return address(300);
    }

    function supportsInterface(bytes4) external pure returns (bool) {
        return true;
    }
}

contract MockVerifier is IVerifierProxy {
    // solhint-disable-next-line const-name-snakecase
    MockVerifierFeeManager private _s_feeManager = new MockVerifierFeeManager();

    function verify(bytes calldata, bytes calldata) external payable returns (bytes memory) {
        return abi.encode(
            BasicReport({
                feedId: "feedId",
                validFromTimestamp: 0,
                observationsTimestamp: 0,
                nativeFee: 0,
                linkFee: 0,
                expiresAt: 0,
                price: 0
            })
        );
    }

    function s_feeManager() external view returns (IVerifierFeeManager) {
        return _s_feeManager;
    }
}
