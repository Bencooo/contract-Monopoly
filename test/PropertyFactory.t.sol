// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Property.sol";
import "../src/PropertyShares.sol";
import "../src/PropertyFactory.sol";

contract PropertyFactoryTest is Test {
    ImmoProperty public propertyContract;
    PropertyFactory public factory;

    function setUp() public {
        propertyContract = new ImmoProperty();
        factory = new PropertyFactory(address(propertyContract));
    }

    function testCreateFullProperty() public {
        // Input values
        string memory name = "Test Villa";
        string memory uri = "https://uri";
        uint256 price = 1 ether;
        string memory erc20Name = "VillaShares";
        string memory erc20Symbol = "VSH";
        uint256 maxSupply = 1000;
        uint256 unitPrice = 0.001 ether;
        string memory meta = "ipfs://meta";

        // Call createFullProperty
        factory.createFullProperty(
            name,
            uri,
            price,
            erc20Name,
            erc20Symbol,
            maxSupply,
            unitPrice,
            meta
        );

        // Get property from ERC721
        ImmoProperty.Property memory p = propertyContract.getProperty(1);

        // Assert property is created correctly
        assertEq(p.name, name);
        assertEq(p.uri, uri);
        assertEq(p.price, price);
        assertEq(p.totalShares, price); // Assuming totalShares = price
        assertEq(p.owner, address(factory));
        assertTrue(p.shareToken != address(0));

        // Check the ERC20 is deployed and correct
        PropertyShares erc20 = PropertyShares(p.shareToken);
        assertEq(erc20.name(), erc20Name);
        assertEq(erc20.symbol(), erc20Symbol);
        assertEq(erc20.getUnitPrice(), unitPrice);
        assertEq(erc20.getMetadataURI(), meta);
        assertEq(erc20.getPropertyId(), 1);
    }

    function testEventEmitted() public {
    // Match uniquement le propertyId (indexed)
    vm.expectEmit(true, false, false, false); 

    emit PropertyFactory.NewPropertyDeployed(1, address(0)); // l’adresse sera ignorée

    factory.createFullProperty(
        "Villa",
        "uri",
        1 ether,
        "S",
        "S",
        1,
        1 ether,
        "meta"
    );
}

}
