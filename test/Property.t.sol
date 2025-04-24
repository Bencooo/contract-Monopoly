// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Property.sol";

contract PropertyTest is Test {
    ImmoProperty public immo;
    address public user = address(0xABCD);
    address public mockShareToken = address(0x1234);

    function setUp() public {
        immo = new ImmoProperty();
        vm.prank(user);
        immo.createProperty("Test Property", "https://uri", 1000 ether, mockShareToken);
    }

    function testCreatePropertyIncrementsCounter() public {
        uint256 counterBefore = immo.propertyCounter();
        vm.prank(user);
        immo.createProperty("Second Property", "https://uri2", 2000 ether, mockShareToken);
        uint256 counterAfter = immo.propertyCounter();
        assertEq(counterAfter, counterBefore + 1);
    }

    function testGetPropertyReturnsCorrectData() public {
        ImmoProperty.Property memory p = immo.getProperty(1);
        assertEq(p.name, "Test Property");
        assertEq(p.uri, "https://uri");
        assertEq(p.price, 1000 ether);
        assertEq(p.totalShares, 1000 ether);
        assertEq(p.owner, user);
        assertEq(p.shareToken, mockShareToken);
    }

    function testCreatePropertyRevertsIfNameEmpty() public {
        vm.expectRevert("Property name cannot be empty");
        vm.prank(user);
        immo.createProperty("", "https://uri", 1000 ether, mockShareToken);
    }

    function testCreatePropertyRevertsIfURIEmpty() public {
        vm.expectRevert("URI cannot be empty");
        vm.prank(user);
        immo.createProperty("Test", "", 1000 ether, mockShareToken);
    }

    function testCreatePropertyRevertsIfPriceZero() public {
        vm.expectRevert("Price must be greater than zero");
        vm.prank(user);
        immo.createProperty("Test", "https://uri", 0, mockShareToken);
    }

    function testCreatePropertyRevertsIfTokenAddressZero() public {
        vm.expectRevert("Invalid ERC20 token address");
        vm.prank(user);
        immo.createProperty("Test", "https://uri", 1000 ether, address(0));
    }

    function testGetInvalidPropertyRevertsWithIdTooHigh() public {
        vm.expectRevert("Property does not exist");
        immo.getProperty(999);
    }

    function testGetInvalidPropertyRevertsWithZeroId() public {
        vm.expectRevert("Property does not exist");
        immo.getProperty(0);
    }

    function testGetPropertiesCount() public {
        assertEq(immo.getPropertiesCount(), 1);
    }

    function testGetShareTokenReturnsCorrectAddress() public {
        address token = immo.getShareToken(1);
        assertEq(token, mockShareToken);
    }

    function testGetShareTokenRevertsIfInvalidId() public {
        vm.expectRevert("Invalid property ID");
        immo.getShareToken(99);
    }
}
