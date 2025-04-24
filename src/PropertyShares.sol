// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PropertyShares is ERC20 {
    uint256 public immutable MAX_SUPPLY;
    uint256 public immutable UNIT_PRICE;
    uint256 public propertyId;
    string public metadataURI;

    error MaxSupplyHit();
    error InsufficientFunds();

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _unitPrice,
        uint256 _propertyId,
        string memory _metadataURI
    ) ERC20(_name, _symbol) {
        require(_unitPrice > 0, "Unit price must be > 0");
        require(_maxSupply > 0, "Max supply must be > 0");

        MAX_SUPPLY = _maxSupply * 10 ** decimals();
        UNIT_PRICE = _unitPrice;
        propertyId = _propertyId;
        metadataURI = _metadataURI;
    }

    modifier withinMaxSupply(uint256 _amount) {
        if (totalSupply() + (_amount * 10 ** decimals()) > MAX_SUPPLY) {
            revert MaxSupplyHit();
        }
        _;
    }

    function mint()
        external
        payable
        withinMaxSupply(msg.value / UNIT_PRICE)
        returns (uint256 minted)
    {
        require(msg.value >= UNIT_PRICE, InsufficientFunds());

        uint256 amountToMint = msg.value / UNIT_PRICE;
        _mint(msg.sender, amountToMint * 10 ** decimals());
        return amountToMint;
    }

    function getUnitPrice() external view returns (uint256) {
        return UNIT_PRICE;
    }

    function getMetadataURI() external view returns (string memory) {
        return metadataURI;
    }

    function getPropertyId() external view returns (uint256) {
        return propertyId;
    }

    /// @notice Nombre de parts encore disponibles à l'achat
    function getAvailableShares() external view returns (uint256) {
        return (MAX_SUPPLY - totalSupply()) / (10 ** decimals());
    }

    /// @notice Nombre de parts déjà mintées (vendues)
    function getSoldShares() external view returns (uint256) {
        return totalSupply() / (10 ** decimals());
    }
}
