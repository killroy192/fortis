// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

/**
 * Fake contract to initialise UpgradeableBeacon
 */
// solhint-disable-next-line no-empty-blocks
contract InitBeacon {
    function test() external pure returns (bool) {
        return true;
    }
}
