// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ImmoProperty is ERC721, Ownable {
    struct Property {
        string name;         
        string uri;          
        uint256 price;       
        uint256 totalShares; 
        address shareToken;  
    }

    uint256 public propertyCounter;
    mapping(uint256 => Property) public properties;

    event PropertyCreated(
        uint256 indexed propertyId, string name, address indexed owner, uint256 totalShares, address shareToken
    );

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) {}

    /// @notice Créer une nouvelle propriété (NFT) et son ERC20 (parts)
    /// @param _name Nom de la propriété
    /// @param _uri URI des métadonnées
    /// @param _price Prix de la propriété (détermine les parts ERC20)
    function createProperty(string memory _name, string memory _uri, uint256 _price) public onlyOwner {
        require(bytes(_name).length > 0, "Property name cannot be empty");
        require(bytes(_uri).length > 0, "URI cannot be empty");
        require(_price > 0, "Price must be greater than zero");

        uint256 _totalShares = _price; // 1 unité = 1 part

        // Déployer le token ERC20 pour cette propriété
        PropertyShares sharesToken = new PropertyShares(_name, "SHARE", _totalShares, msg.sender);
        
        propertyCounter++;
        uint256 propertyId = propertyCounter;

      
        properties[propertyId] = Property({
            name: _name,
            uri: _uri,
            price: _price,
            totalShares: _totalShares,
            shareToken: address(sharesToken)
        });

    
        _mint(msg.sender, propertyId);

        emit PropertyCreated(propertyId, _name, msg.sender, _totalShares, address(sharesToken));
    }

    /// @notice Récupérer une propriété par son ID
    function getProperty(uint256 propertyId) public view returns (Property memory) {
        require(propertyId > 0 && propertyId <= propertyCounter, "Property does not exist");
        return properties[propertyId];
    }

    /// @notice Retourner l'URI du NFT (norme ERC721)
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId < propertyCounter, "Token does not exist");
        return properties[tokenId].uri;
    }
}

/// @notice Contrat ERC20 pour représenter les parts de propriété
contract PropertyShares is ERC20 {
    uint256 public immutable MAX_SUPPLY;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply, address _owner) 
        ERC20(_name, _symbol) 
    {
        MAX_SUPPLY = _maxSupply * 10 ** decimals();
        _mint(_owner, MAX_SUPPLY); // Mint toutes les parts à l'agence immobilière
    }

    /// @notice Permet au propriétaire de transférer des parts à des investisseurs
    function distributeShares(address _to, uint256 _amount) public {
        require(balanceOf(msg.sender) >= _amount, "Not enough shares");
        _transfer(msg.sender, _to, _amount);
    }
}