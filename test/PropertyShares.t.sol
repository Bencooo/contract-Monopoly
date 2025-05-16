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
    uint256 public constant PROPERTY_PRICE = 1 ether;

    function setUp() public {
        shares = new PropertyShares(
            "Villa Shares",
            "VLS",
            MAX_SUPPLY,
            UNIT_PRICE,
            1,
            PROPERTY_PRICE,
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
        assertEq(
            shares.getExpectedMonthlyRevenue(),
            (PROPERTY_PRICE * ANNUAL_YIELD) / 10000 / 12
        );
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

    function testGettersAfterMint() public {
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
            PROPERTY_PRICE,
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
            PROPERTY_PRICE,
            "ipfs://villa-metadata",
            ANNUAL_YIELD
        );
    }

    function testClaimableRevenueAndClaim() public {
        vm.deal(user, 1 ether);
        vm.prank(user);
        shares.mint{value: 0.01 ether}(); // 1 part

        // Inject ETH into contract for distribution
        vm.deal(address(this), 1 ether);
        payable(address(shares)).transfer(shares.getExpectedMonthlyRevenue());

        // Distribute
        shares.distributeMonthlyYield();

        uint256 claimable = shares.getClaimableRevenue(user);
        assertGt(claimable, 0);

        uint256 balanceBefore = user.balance;
        vm.prank(user);
        shares.claimRevenue();
        uint256 balanceAfter = user.balance;

        assertEq(shares.getClaimableRevenue(user), 0);
        assertGt(balanceAfter, balanceBefore);
    }

    function testDistributeFailsIfNotEnoughBalance() public {
        vm.expectRevert("No supply");
        shares.distributeMonthlyYield();
    }

    function testReceiveETHDirectly() public {
        vm.deal(address(this), 1 ether);
        payable(address(shares)).transfer(0.01 ether);
        assertEq(address(shares).balance, 0.01 ether);
    }

    function testClaimRevenueFailsIfNothingToClaim() public {
        vm.expectRevert("Nothing to claim");
        vm.prank(user);
        shares.claimRevenue();
    }

    function testEarnedWithoutMintIsZero() public {
        uint256 result = shares.earned(user);
        assertEq(result, 0);
    }

    function testRewardPerTokenWithoutDistribution() public {
        uint256 value = shares.currentRewardPerToken();
        assertEq(value, 0);
    }

    function testUpdateRewardWithZeroAddress() public {
        // Mint 1 part pour avoir un totalSupply > 0
        vm.deal(user, 1 ether);
        vm.prank(user);
        shares.mint{value: UNIT_PRICE}();

        // Injecter des fonds dans le contrat (sinon revert)
        vm.deal(address(this), 1 ether);
        payable(address(shares)).transfer(shares.getExpectedMonthlyRevenue());

        // Appelle la fonction qui utilise updateReward(address(0))
        shares.distributeMonthlyYield();

        // Vérifie que la reward a bien été mise à jour
        uint256 value = shares.currentRewardPerToken();
        assertGt(value, 0);
    }

    function testRewardPerTokenWhenSupplyPositive() public {
        // Mint
        vm.deal(user, 1 ether);
        vm.prank(user);
        shares.mint{value: UNIT_PRICE}();

        // Inject + distribuer
        vm.deal(address(this), 1 ether);
        payable(address(shares)).transfer(shares.getExpectedMonthlyRevenue());
        shares.distributeMonthlyYield();

        // Appel rewardPerToken avec totalSupply > 0
        uint256 value = shares.currentRewardPerToken();
        assertGt(value, 0);
    }

    function testUpdateRewardWhenAddressIsZeroSkippedLogic() public {
    // supply > 0 pour ne pas revert
    vm.deal(user, 1 ether);
    vm.prank(user);
    shares.mint{value: UNIT_PRICE}();

    // injecte ETH sans distribution
    vm.deal(address(this), 1 ether);
    payable(address(shares)).transfer(shares.getExpectedMonthlyRevenue());

    // Appelle distributeMonthlyYield (force updateReward(address(0)))
    shares.distributeMonthlyYield();

    // Si ça n’a pas revert, on a traversé les deux branches
    assertTrue(true);
}

function testCurrentRewardPerTokenWhenSupplyPositive() public {
    vm.deal(user, 1 ether);
    vm.prank(user);
    shares.mint{value: UNIT_PRICE}();

    vm.deal(address(this), 1 ether);
    payable(address(shares)).transfer(shares.getExpectedMonthlyRevenue());

    shares.distributeMonthlyYield();

    uint256 value = shares.currentRewardPerToken();
    assertGt(value, 0);
}
    
}
