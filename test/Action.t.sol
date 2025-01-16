// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Action} from "../src/Action.sol";

contract ActionTest is Test {
    Action public action;

    function setUp() public {
        action = new Action("MyLoge", "ML", 450000);
    }

    function testInitialize() public {
        assertEq("MyLoge", action.name());
        assertEq("ML", action.symbol());
        assertEq(450000 * 10 ** 18, action.MAX_SUPPLY());
        assertEq(0.001 ether, action.PRICE());
    }

    function testMint() public {
        action.mint{value: 0.1 ether}();
        assertEq(100, action.balanceOf(address(this)));
        assertEq(0.1 ether, address(action).balance);
        vm.expectRevert(abi.encodeWithSelector(Action.INSUFFICIENT_FUNDS.selector));
        action.mint();
        vm.expectRevert(abi.encodeWithSelector(Action.MAX_SUPPLY_HIT.selector));
        action.mint{value: 450000 * 1 ether}();
    }
}
