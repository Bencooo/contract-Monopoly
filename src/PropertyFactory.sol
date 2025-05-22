// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Property.sol";
import "./PropertyShares.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Roles.sol";

contract PropertyFactory is AccessControl {
    ImmoProperty public propertyContract;

    event NewPropertyDeployed(uint256 propertyId, address erc20Token);

    constructor(address _propertyContract) {
        _grantRole(Roles.DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(Roles.PROPERTY_MANAGER_ROLE, msg.sender);

        propertyContract = ImmoProperty(_propertyContract);
    }

    /// @notice Crée un bien immobilier ERC721 + ses parts ERC20
    function createFullProperty(
        string memory propertyName,
        string memory propertyURI,
        uint256 displayPrice, /// @param displayPrice Prix affiché dans le frontend (ERC721)
        string memory erc20Name,
        string memory erc20Symbol,
        uint256 erc20MaxSupply,
        uint256 unitPrice,
        string memory metadataURI,
        uint256 annualYield,
        uint256 propertyPrice, /// @param propertyPrice Prix réel utilisé pour calculer le yield (ERC20)
        address admin
    ) external onlyRole(Roles.PROPERTY_MANAGER_ROLE) {
        // Récupérer l'ID du NFT à venir
        uint256 propertyId = propertyContract.propertyCounter() + 1;

        // Déployer l'ERC20 pour les parts
        PropertyShares shareToken = new PropertyShares(
            erc20Name,
            erc20Symbol,
            erc20MaxSupply,
            unitPrice,
            propertyId,
            propertyPrice,
            metadataURI,
            annualYield,
            admin
        );

        // Créer la propriété ERC721 et lier l'ERC20
        propertyContract.createProperty(
            propertyName,
            propertyURI,
            displayPrice,
            address(shareToken)
        );

        emit NewPropertyDeployed(propertyId, address(shareToken));
    }
}
