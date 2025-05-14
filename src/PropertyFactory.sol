// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Property.sol";
import "./PropertyShares.sol";

contract PropertyFactory {
    ImmoProperty public propertyContract;

    event NewPropertyDeployed(uint256 propertyId, address erc20Token);

    constructor(address _propertyContract) {
        propertyContract = ImmoProperty(_propertyContract);
    }

    /// @notice Crée un bien immobilier ERC721 + ses parts ERC20
    function createFullProperty(
        string memory propertyName,
        string memory propertyURI,
        uint256 propertyPrice,
        string memory erc20Name,
        string memory erc20Symbol,
        uint256 erc20MaxSupply,
        uint256 unitPrice,
        string memory metadataURI,
        uint256 annualYield
    ) external {
        // Récupérer l'ID du NFT à venir
        uint256 propertyId = propertyContract.propertyCounter() + 1;

        // Déployer l'ERC20 pour les parts
        PropertyShares shareToken = new PropertyShares(
            erc20Name,
            erc20Symbol,
            erc20MaxSupply,
            unitPrice,
            propertyId,
            metadataURI,
            annualYield
        );

        // Créer la propriété ERC721 et lier l'ERC20
        propertyContract.createProperty(
            propertyName,
            propertyURI,
            propertyPrice,
            address(shareToken)
        );

        emit NewPropertyDeployed(propertyId, address(shareToken));
    }
}
