// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.16;

// solhint-disable no-global-import
// solhint-disable no-console

import "@std/Test.sol";

import {Template} from "src/Template.sol";

contract TemplateTest is Test {
    Template private template;

    function setUp() public {
        template = new Template();
    }

    function test_hello() public {
        assertEq(template.hello(), "hello world");
    }
}
