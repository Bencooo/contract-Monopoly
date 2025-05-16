// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Property.sol";
import "../src/PropertyShares.sol";
import "../src/PropertyFactory.sol";

contract PropertyFactoryTest is Test {
    ImmoProperty public propertyContract;
    PropertyFactory public factory;

    uint256 public constant annualYield = 800; // 8%
    uint256 public constant displayPrice = 1 ether;
    uint256 public constant propertyPrice = 0.02 ether;
    uint256 public constant unitPrice = 0.0002 ether;
    uint256 public constant maxSupply = 100;

    function setUp() public {
        propertyContract = new ImmoProperty();
        factory = new PropertyFactory(address(propertyContract));
    }

    function testCreateFullProperty() public {
        string memory name = "Villa Test";
        string memory uri = "https://villa.test/uri";
        string memory meta = "ipfs://villa-meta";
        string memory symbol = "VTS";

        // Call
        factory.createFullProperty(
            name,
            uri,
            displayPrice,
            "VillaToken",
            symbol,
            maxSupply,
            unitPrice,
            meta,
            annualYield,
            propertyPrice
        );

        // Check property (ERC721)
        ImmoProperty.Property memory p = propertyContract.getProperty(1);
        assertEq(p.name, name);
        assertEq(p.uri, uri);
        assertEq(p.price, displayPrice);
        assertEq(p.totalShares, displayPrice);
        assertEq(p.owner, address(factory));
        assertTrue(p.shareToken != address(0));

        // Check ERC20 token
        PropertyShares token = PropertyShares(payable(p.shareToken));
        assertEq(token.name(), "VillaToken");
        assertEq(token.symbol(), symbol);
        assertEq(token.getUnitPrice(), unitPrice);
        assertEq(token.getMetadataURI(), meta);
        assertEq(token.getPropertyId(), 1);
        assertEq(token.getAnnualYield(), annualYield);
        assertEq(token.getExpectedMonthlyRevenue(), (propertyPrice * annualYield) / 10000 / 12);
    }

    function testEventEmitted() public {
        vm.expectEmit(true, false, false, false);
        emit PropertyFactory.NewPropertyDeployed(1, address(0)); // ERC20 ignorée

        factory.createFullProperty(
            "Villa",
            "uri",
            displayPrice,
            "Token",
            "TOK",
            maxSupply,
            unitPrice,
            "meta",
            annualYield,
            propertyPrice
        );
    }
}
