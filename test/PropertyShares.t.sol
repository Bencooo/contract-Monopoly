// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/PropertyShares.sol";

contract PropertySharesTest is Test {
    PropertyShares public shares;
    address public user = address(0xABCD);

    uint256 public constant MAX_SUPPLY = 1000;
    uint256 public constant UNIT_PRICE = 0.01 ether;
    uint256 public constant ANNUAL_YIELD = 800; // 8.00%

    function setUp() public {
        shares = new PropertyShares(
            "Villa Shares",
            "VLS",
            MAX_SUPPLY,
            UNIT_PRICE,
            1,
            "ipfs://villa-metadata",
            ANNUAL_YIELD
        );
    }

    function testInitialValues() public {
        assertEq(shares.name(), "Villa Shares");
        assertEq(shares.symbol(), "VLS");
        assertEq(shares.getUnitPrice(), UNIT_PRICE);
        assertEq(shares.getPropertyId(), 1);
        assertEq(shares.getMetadataURI(), "ipfs://villa-metadata");
        assertEq(shares.getAnnualYield(), ANNUAL_YIELD);
        assertEq(shares.MAX_SUPPLY(), MAX_SUPPLY * 10 ** shares.decimals());
        assertEq(shares.totalSupply(), 0);
    }

    function testMintSuccess() public {
        vm.deal(user, 1 ether); // Donne de l'ETH à l'utilisateur
        vm.prank(user);
        shares.mint{value: 0.05 ether}(); // 5 parts

        uint256 expected = 5 * 10 ** shares.decimals();
        assertEq(shares.totalSupply(), expected);
        assertEq(shares.balanceOf(user), expected);
        assertEq(shares.getAvailableShares(), MAX_SUPPLY - 5);
        assertEq(shares.getSoldShares(), 5);
    }

    function testMintNotEnoughFunds() public {
        vm.expectRevert(PropertyShares.InsufficientFunds.selector);
        shares.mint{value: 0.001 ether}(); // Moins que UNIT_PRICE
    }

    function testMaxSupplyHit() public {
        vm.deal(user, 100 ether); // Donne beaucoup d'ETH à l'utilisateur
        vm.prank(user);
        shares.mint{value: MAX_SUPPLY * UNIT_PRICE}(); // Mint tout

        assertEq(shares.getSoldShares(), MAX_SUPPLY);
        assertEq(shares.getAvailableShares(), 0);

        // Essaye de dépasser le max
        vm.expectRevert(PropertyShares.MaxSupplyHit.selector);
        vm.prank(user);
        shares.mint{value: 0.01 ether}();
    }

    function testGettersAreCorrectAfterMint() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        shares.mint{value: 0.03 ether}(); // 3 parts

        assertEq(shares.getSoldShares(), 3);
        assertEq(shares.getAvailableShares(), 997);
    }

    function testConstructorRevertsIfSupplyZero() public {
    vm.expectRevert("Max supply must be > 0");
    new PropertyShares(
        "Villa Shares",
        "VLS",
        0, // max supply = 0 → revert
        UNIT_PRICE,
        1,
        "ipfs://villa-metadata",
        ANNUAL_YIELD
    );
}

function testConstructorRevertsIfPriceZero() public {
    vm.expectRevert("Unit price must be > 0");
    new PropertyShares(
        "Villa Shares",
        "VLS",
        MAX_SUPPLY,
        0, // unit price = 0 → revert
        1,
        "ipfs://villa-metadata",
        ANNUAL_YIELD
    );
}

}
