// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {ImmoProperty} from "../src/Property.sol";

contract PropertyScript is Script {
    function run() external {
        vm.startBroadcast();

        ImmoProperty immoProperty = new ImmoProperty("My property", "MPY");
        //console.log("ImmoProperty contract deployed at:", address(immoProperty));

        

        immoProperty.createProperty(
            "Villa", "https://villa/image", 1000, address(0x81C9A3b742E42E4513dAED893108F17E3430bf84)
        );

        //console.log("Get Property: ");
        ImmoProperty.Property memory property1 = immoProperty.getProperty(1);
        //console.log("Property 1: Name:", property1.name);
        //console.log("Property 1: Price:", property1.price);
        //console.log("Property 1: Owner:", property1.owner);
        //console.log("Property 1: URI:", property1.uri);

        vm.stopBroadcast();
    }
}
