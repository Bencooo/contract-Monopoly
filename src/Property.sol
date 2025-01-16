// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract ImmoProperty is ERC721 {
    struct Property {
        string name;
        string uri; // Métadonnées
        uint256 price;
        uint256 totalShares; // Nombre total de parts (totalSupply du ERC20)
        address owner;
        address shareToken; // Adresse du token ERC20
    }

    uint256 public propertyCounter;
    mapping(uint256 => Property) public properties;

    event PropertyCreated(
        uint256 indexed propertyId, string name, address indexed owner, uint256 totalShares, address shareToken
    );

    /// @notice Initialisation du contrat ERC721
    /// @param name Nom global du token ERC721
    /// @param symbol Symbole global du token ERC721
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    /// @notice Créer une nouvelle propriété
    /// @param _name Nom de la propriété
    /// @param _uri URI des métadonnées
    /// @param _price Prix de la propriété
    /// @param _shareToken Adresse du token ERC20 associé aux parts
    function createProperty(string memory _name, string memory _uri, uint256 _price, address _shareToken) public {
        require(bytes(_name).length > 0, "Property name cannot be empty");
        require(bytes(_uri).length > 0, "URI cannot be empty");
        require(_price > 0, "Price must be greater than zero");
        require(_shareToken != address(0), "Invalid share token address");

        uint256 _totalShares = _price; // TotalShares = Price pour faire simple (1$ = 1 part)

        propertyCounter++;
        uint256 propertyId = propertyCounter;

        properties[propertyId] = Property({
            name: _name,
            uri: _uri,
            price: _price,
            totalShares: _totalShares,
            owner: msg.sender,
            shareToken: _shareToken
        });

        _mint(msg.sender, propertyId);

        emit PropertyCreated(propertyId, _name, msg.sender, _totalShares, _shareToken);
    }

    function getProperty(uint256 propertyId) public view returns (Property memory) {
        require(propertyId > 0 && propertyId <= propertyCounter, "Property does not exist");
        return properties[propertyId];
    }
}
