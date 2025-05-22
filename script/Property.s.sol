// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ImmoProperty} from "../src/Property.sol";
import {PropertyShares} from "../src/PropertyShares.sol";

contract PropertyScript is Script {
    function run() external {
        vm.startBroadcast();

        // 1. Déployer le contrat ERC721 (résidence)
        ImmoProperty immoProperty = new ImmoProperty();
        console.log("ImmoProperty (ERC721) deployed at:", address(immoProperty));

        // 2. Déployer l’ERC20 lié à cette résidence
        PropertyShares shares = new PropertyShares(
            "Villa Shares",         // nom ERC20
            "VLS",                  // symbole ERC20
            1000,                   // max supply = 1000 parts
            0.0002 ether,           // unit price = 0.0002 ETH la part
            1,                      // propertyId (provisoire)
            0.02 ether,             // valeur totale du bien
            "ipfs://villa-metadata",// metadata URI
            800,                     // annual yield = 8.00%
            msg.sender
        );
        console.log("PropertyShares (ERC20) deployed at:", address(shares));

        // 3. Créer la propriété avec l’adresse du token ERC20
        immoProperty.createProperty(
            "Villa residence",
            "https://villa/image",
            1000 ether,            // prix total en ETH
            address(shares)       // 🧩 lien ERC20
        );

        // 4. Lecture de la propriété créée
        ImmoProperty.Property memory property1 = immoProperty.getProperty(1);
        console.log("Property ID 1:");
        console.log("Name:", property1.name);
        console.log("Price:", property1.price);
        console.log("Owner:", property1.owner);
        console.log("URI:", property1.uri);
        console.log("Linked ERC20 token:", property1.shareToken);

        vm.stopBroadcast();
    }
}
