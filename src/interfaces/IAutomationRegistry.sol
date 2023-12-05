// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

interface IAutomationRegistry {
    function addFunds(uint256 id, uint96 amount) external;
}
