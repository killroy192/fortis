// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FWETH is ERC20 {
    event Deposit(address indexed dst, uint256 val);
    event Withdrawal(address indexed src, uint256 val);

    error TransferFailed();

    // solhint-disable-next-line no-empty-blocks
    constructor() ERC20("Fortis WETH", "fWETH") {}

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }

    function deposit() public payable {
        _mint(msg.sender, msg.value);
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 val) public {
        (bool callSuccess,) = msg.sender.call{value: val}("");

        if (!callSuccess) {
            revert TransferFailed();
        }

        _burn(msg.sender, val);

        emit Withdrawal(msg.sender, val);
    }
}
