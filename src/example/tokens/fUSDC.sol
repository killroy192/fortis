// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FUSDC is ERC20, Ownable {
    // solhint-disable-next-line no-empty-blocks
    constructor() ERC20("Fortis USDC", "fUSDC") Ownable(msg.sender) {}

    function decimals() public pure override returns (uint8) {
        return 6;
    }

    function mint(address account, uint256 value) external onlyOwner {
        _mint(account, value);
    }
}
