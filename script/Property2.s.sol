// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.13;

// import {Script} from "forge-std/Script.sol";
// import {console} from "forge-std/console.sol";
// import {ImmoProperty} from "../src/Property2.sol";

// contract PropertyScript is Script {
//     function run() external {
//         vm.startBroadcast();

//         // Déploiement du contrat ImmoProperty
//         string memory name = "ImmoNFT";
//         string memory symbol = "IMN";
//         ImmoProperty immoProperty = new ImmoProperty(name, symbol);
//         console.log("ImmoProperty deployed at:", address(immoProperty));

//         // Création d'une propriété
//         string memory propertyName = "Villa Luxueuse";
//         string memory propertyURI = "https://example.com/properties/1";
//         uint256 price = 1000;
        
//         immoProperty.createProperty(propertyName, propertyURI, price);
//         console.log("Property created with ID:", 1);

//         // Récupération des informations de la propriété
//         ImmoProperty.Property memory prop = immoProperty.getProperty(1);
//         console.log("Property Name:", prop.name);
//         console.log("Property Price:", prop.price);
//         console.log("Property Owner:", prop.shareToken);
//         console.log("Property URI:", prop.uri);

//         vm.stopBroadcast();
//     }
// }
