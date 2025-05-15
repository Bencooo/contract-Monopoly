// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import {ImmoProperty} from "../src/Property.sol";
import {PropertyShares} from "../src/PropertyShares.sol";
import {PropertyFactory} from "../src/PropertyFactory.sol";

contract FullPropertyFlow is Script {
    function run() external {
        vm.startBroadcast();

        // 1. Déploiement du contrat ERC721
        ImmoProperty immo = new ImmoProperty();
        console.log("ImmoProperty deployed at:", address(immo));

        // 2. Déploiement de la factory
        PropertyFactory factory = new PropertyFactory(address(immo));
        console.log("Factory deployed at:", address(factory));

        // 3. Création d'une propriété + token ERC20 via la factory
        factory.createFullProperty(
            "Villa Palmeraie",
            "https://ipfs.io/villa/palmeraie",
            1 ether,                     // Prix affiché
            "Palmeraie Shares",
            "PLM",
            1000,
            0.00001 ether,              // ✅ Part très peu chère
            "ipfs://villa-metadata",
            800,                        // 8%
            0.001 ether                 // ✅ Valeur économique du bien (très faible)
        );
        console.log("Property and ERC20 token created via factory");

        // 4. Lecture de la propriété #1
        ImmoProperty.Property memory p = immo.getProperty(1);
        console.log("Property #1:");
        console.log("Name:", p.name);
        console.log("Price:", p.price / 1 ether, "ETH");
        console.log("Token address:", p.shareToken);

        // 5. Caster et interagir avec le token
        PropertyShares token = PropertyShares(payable(p.shareToken));

        // 6. Mint 1 part (0.00001 ETH)
        token.mint{value: 0.00001 ether}();
        console.log("Minted 1 share");

        // 7. Injecter un petit revenu (0.0000066 ETH attendu)
        payable(address(token)).transfer(0.0000066 ether);
        token.distributeMonthlyYield();
        console.log("Yield distributed");

        // 8. Lire le revenu récupérable
        uint256 revenue = token.getClaimableRevenue(msg.sender);
        console.log("Claimable:", revenue);

        // 9. Claim
        token.claimRevenue();
        console.log("Revenue claimed");

        vm.stopBroadcast();
    }
}
