// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

import {IAsset} from "./IAsset.sol";

interface IFeeManager {
    function getFeeAndReward(
        address subscriber,
        bytes memory unverifiedReport,
        address quoteAddress
    ) external returns (IAsset memory, IAsset memory, uint256);

    function i_linkAddress() external view returns (address);

    function i_nativeAddress() external view returns (address);

    function i_rewardManager() external view returns (address);
}
