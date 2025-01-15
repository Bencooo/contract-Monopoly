// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ImmoProperty is ERC721 {
    struct Property {
        string name;
        string uri;
        address owner;
        uint256 totalShares;
        address shareToken;
    }

    mapping(uint256 => Property) public properties;

    constructor(string memory name, string memory symbol) ERC721 (name, symbol){}

    uint256 public propertyCounter; 
    mapping(uint256 => Property) public properties; 
}
