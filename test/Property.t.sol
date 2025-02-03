// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {ImmoProperty} from "../src/Property.sol";

contract PropertyTest is Test {
    ImmoProperty public property;

    function setUp() public {
        property = new ImmoProperty("Test","TEST");
    }

    function testVariable() public {
        assertEq("Test",property.name());
        assertEq("TEST",property.symbol());
        assertEq(0,property.propertyCounter());
    }



}
