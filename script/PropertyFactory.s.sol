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

        // 1. Deploy ERC721 contract
        ImmoProperty immo = new ImmoProperty();
        console.log("ImmoProperty deployed at:", address(immo));

        // 2. Deploy factory
        PropertyFactory factory = new PropertyFactory(address(immo));
        console.log("Factory deployed at:", address(factory));

        // 3. Create property with ERC20 shares
        factory.createFullProperty(
            "Villa Palmeraie",
            "https://ipfs.io/villa/palmeraie",
            1 ether, // Total price of the property
            "Palmeraie Shares",
            "PLM",
            5, // 1 part max
            0.0000001 ether, // 1 part = 0.0000001 ETH
            "ipfs://villa-metadata",
            800                           // annualYield = 8.00%
        );
        console.log("Property and ERC20 token created via factory");

        // 4. Fetch property
        ImmoProperty.Property memory p = immo.getProperty(1);
        console.log("Property #1:");
        console.log("Name:", p.name);
        console.log("URI:", p.uri);
        console.log("Price:", p.price / 1 ether, "ETH");
        console.log("Total shares:", p.totalShares);
        console.log("Owner:", p.owner);
        console.log("ERC20 token address:", p.shareToken);

        // 5. Interact with ERC20
        PropertyShares token = PropertyShares(p.shareToken);

        // 6. Check balance
        uint256 requiredValue = 0.0000001 ether;
        uint256 balance = tx.origin.balance;
        console.log("Wallet balance:", balance, "wei");

        require(balance >= requiredValue, "Not enough ETH for mint");

        // 7. Mint 1 share
        token.mint{value: requiredValue}();
        console.log("Minted 1 share at 0.0000001 ETH");

        // 8. Display stats
        console.log("Sold shares:", token.getSoldShares());
        console.log("Available shares:", token.getAvailableShares());
        console.log("Annual Yield:", token.getAnnualYield());
        console.log("Balance of: %s", tx.origin);
        console.log("Shares: %s", token.balanceOf(tx.origin) / 1e18);

        vm.stopBroadcast();
    }
}
