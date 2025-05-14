// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/PropertyShares.sol";

contract PropertySharesScript is Script {
    function run() external {
        // 1. Préparer la clé privée pour signer les tx
        vm.startBroadcast();

        // 2. Déploiement du contrat PropertyShares
        PropertyShares shares = new PropertyShares(
            "Villa Kenza Shares",   // name
            "KENZA",                // symbol
            1000,                   // max supply (1000 parts)
            0.01 ether,             // unit price (0.01 ETH la part)
            1,                      // propertyId (ex: tokenId 1 de ERC721)
            "ipfs://villa-metadata", // metadata URI
            800                        // annualYield = 8.00%
        );

        console.log("Contract deployed at:", address(shares));
        console.log("Property ID:", shares.getPropertyId());
        console.log("Unit Price:", shares.getUnitPrice());
        console.log("Max Supply (raw):", shares.MAX_SUPPLY());
        console.log("Annual Yield:", shares.getAnnualYield());

        // 3. Tester le mint avec 0.05 ETH (5 parts)
        shares.mint{value: 0.05 ether}();

        console.log("Minted 5 shares to:", msg.sender);
        console.log("Balance of sender:", shares.balanceOf(msg.sender));

        // 4. Nouvelles fonctions : parts dispo / vendues
        console.log("Available Shares:", shares.getAvailableShares());
        console.log("Sold Shares:", shares.getSoldShares());

        vm.stopBroadcast();
    }
}
