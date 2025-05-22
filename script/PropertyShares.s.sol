// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "../src/PropertyShares.sol";
import "../src/Roles.sol";

contract PropertySharesScript is Script {
    function run() external {
        address user = msg.sender;

        vm.startBroadcast();

        // 1. Déployer le contrat avec un petit propertyPrice pour test
        PropertyShares shares = new PropertyShares(
            "Villa Mini Shares",
            "MINI",
            1000, // max supply
            0.0002 ether, // unit price
            1, // propertyId
            0.02 ether, // propertyPrice (basse pour distribuer peu)
            "ipfs://villa-mini", // metadata
            800, // annual yield = 8%
            user
        );

        console.log("Contract deployed at:", address(shares));
        console.log(
            "Expected monthly revenue:",
            shares.getExpectedMonthlyRevenue()
        );

        // 2. Grant le rôle de Yield Manager à msg.sender si ce n'est pas déjà fait
        if (!shares.hasRole(Roles.YIELD_MANAGER_ROLE, user)) {
            shares.grantRole(Roles.YIELD_MANAGER_ROLE, user);
            console.log("Granted YIELD_MANAGER_ROLE to:", user);
        }

        // 3. Mint 1 part (0.0002 ETH)
        shares.mint{value: 0.0002 ether}();
        console.log("Minted 1 part to:", msg.sender);

        // 4. Fund le contrat manuellement avec un montant >= expectedMonthlyRevenue
        uint256 monthlyRevenue = shares.getExpectedMonthlyRevenue(); // ≈ 0.000133 ETH
        payable(address(shares)).transfer(monthlyRevenue);
        console.log("Contract funded with:", monthlyRevenue);

        // 5. Lancer la distribution automatique depuis les fonds du contrat
        shares.distributeMonthlyYield();
        console.log("Yield distributed from contract balance");

        // 6. Vérifier ce que le user peut récupérer
        uint256 claimable = shares.getClaimableRevenue(msg.sender);
        console.log("Claimable revenue for:");
        console.logAddress(msg.sender);
        console.log("Amount (wei):", claimable);

        // 7. Récupération du revenu
        shares.claimRevenue();
        console.log("Revenue claimed");

        // 8. Vérification post-claim
        uint256 afterClaim = shares.getClaimableRevenue(msg.sender);
        console.log("Remaining after claim:", afterClaim, "wei");

        vm.stopBroadcast();
    }
}
