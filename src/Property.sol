// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract ImmoProperty is ERC721URIStorage {
    struct Property {
        string name;
        string uri; // Métadonnées
        uint256 price;
        uint256 totalShares; // Nombre total de parts (totalSupply du ERC20)
        address owner;
    }

    uint256 public propertyCounter;
    mapping(uint256 => Property) public properties;

    event PropertyCreated(
        uint256 indexed propertyId,
        string name,
        address indexed owner,
        uint256 totalShares
    );

    constructor() ERC721("Monopoly Real Estate", "MONO") {}

    function createProperty(
        string memory _name,
        string memory _uri,
        uint256 _price
    ) public {
        require(bytes(_name).length > 0, "Property name cannot be empty");
        require(bytes(_uri).length > 0, "URI cannot be empty");
        require(_price > 0, "Price must be greater than zero");

        uint256 _totalShares = _price; // 1 token = 1€

        propertyCounter++;
        uint256 propertyId = propertyCounter;

        properties[propertyId] = Property({
            name: _name,
            uri: _uri,
            price: _price,
            totalShares: _totalShares,
            owner: msg.sender
        });

        _safeMint(msg.sender, propertyId);
        //_setTokenURI(propertyId, _uri);

        emit PropertyCreated(propertyId, _name, msg.sender, _totalShares);
    }

    function getProperty(uint256 propertyId) public view returns (Property memory) {
        require(propertyId > 0 && propertyId <= propertyCounter, "Property does not exist");
        return properties[propertyId];
    }

    function getPropertiesCount() public view returns (uint256) {
        return propertyCounter;
    }
}
