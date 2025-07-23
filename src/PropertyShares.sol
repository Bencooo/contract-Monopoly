// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Roles.sol";

contract PropertyShares is ERC20, AccessControl {
    uint256 public immutable MAX_SUPPLY;
    uint256 public immutable UNIT_PRICE;
    uint256 public propertyId;
    uint256 public propertyPrice;
    uint256 public annualYield;
    string public metadataURI;

    // Revenus
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public claimableRevenue;

    event YieldDistributed(uint256 propertyId, uint256 amount, uint256 timestamp);
    event TokensPurchased(address indexed investor, uint256 amount, uint256 newTotalSupply);
    event RevenueClaimed(address indexed investor, uint256 amount, uint256 timestamp);

    error MaxSupplyHit();
    error InsufficientFunds();
    error NothingToClaim();

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        uint256 _unitPrice,
        uint256 _propertyId,
        uint256 _propertyPrice,
        string memory _metadataURI,
        uint256 _annualYield,
        address admin
    ) ERC20(_name, _symbol) {
        _grantRole(Roles.DEFAULT_ADMIN_ROLE, admin);
        _grantRole(Roles.YIELD_MANAGER_ROLE, admin);

        require(_unitPrice > 0, "Unit price must be > 0");
        require(_maxSupply > 0, "Max supply must be > 0");
        require(_propertyPrice > 0, "Property price must be > 0");

        MAX_SUPPLY = _maxSupply * 10 ** decimals();
        UNIT_PRICE = _unitPrice;
        propertyId = _propertyId;
        propertyPrice = _propertyPrice;
        metadataURI = _metadataURI;
        annualYield = _annualYield;
    }

    modifier withinMaxSupply(uint256 _amount) {
        if (totalSupply() + (_amount * 10 ** decimals()) > MAX_SUPPLY) {
            revert MaxSupplyHit();
        }
        _;
    }

    modifier updateReward(address user) {
        rewardPerTokenStored = currentRewardPerToken();
        if (user != address(0)) {
            claimableRevenue[user] = earned(user);
            userRewardPerTokenPaid[user] = rewardPerTokenStored;
        }
        _;
    }

    function mint()
        external
        payable
        withinMaxSupply(msg.value / UNIT_PRICE)
        updateReward(msg.sender)
        returns (uint256 minted)
    {
        require(msg.value >= UNIT_PRICE, InsufficientFunds());

        uint256 amountToMint = msg.value / UNIT_PRICE;
        _mint(msg.sender, amountToMint * 10 ** decimals());
        emit TokensPurchased(msg.sender, amountToMint * 10 ** decimals(), totalSupply());
        return amountToMint;
    }

    /// @notice Permet au contrat de recevoir des ETH
    receive() external payable {}

    /// @notice Calcule le revenu mensuel estimé basé sur le yield annuel
    function getExpectedMonthlyRevenue() public view returns (uint256) {
        return (propertyPrice * annualYield) / 10000 / 12;
    }

    /// @notice Injecte le revenu mensuel à distribuer
    function distributeMonthlyYield() external onlyRole(Roles.YIELD_MANAGER_ROLE) updateReward(address(0)) {
        require(totalSupply() > 0, "No supply");

        uint256 monthlyRevenue = (propertyPrice * annualYield) / 10000 / 12;
        require(
            address(this).balance >= monthlyRevenue,
            "Not enough balance in contract"
        );

        rewardPerTokenStored += (monthlyRevenue * 1e18) / totalSupply();
        emit YieldDistributed(propertyId, monthlyRevenue, block.timestamp);
    }

    /// @notice Calcule la récompense par token
    function currentRewardPerToken() public view returns (uint256) {
        if (totalSupply() == 0) return rewardPerTokenStored;
        return rewardPerTokenStored;
    }

    /// @notice Calcule les gains de l'utilisateur
    function earned(address user) public view returns (uint256) {
        uint256 userBalance = balanceOf(user);
        return
            ((userBalance *
                (currentRewardPerToken() - userRewardPerTokenPaid[user])) /
                1e18) + claimableRevenue[user];
    }

    /// @notice L'utilisateur retire ses revenus
    function claimRevenue() external updateReward(msg.sender) {
        uint256 amount = claimableRevenue[msg.sender];
        require(amount > 0, "Nothing to claim");

        claimableRevenue[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
        emit RevenueClaimed(msg.sender, amount, block.timestamp);
    }

    // Infos
    function getUnitPrice() external view returns (uint256) {
        return UNIT_PRICE;
    }

    function getMetadataURI() external view returns (string memory) {
        return metadataURI;
    }

    function getPropertyId() external view returns (uint256) {
        return propertyId;
    }

    function getAnnualYield() external view returns (uint256) {
        return annualYield;
    }

    /// @notice Nombre de parts encore disponibles à l'achat
    function getAvailableShares() external view returns (uint256) {
        return (MAX_SUPPLY - totalSupply()) / (10 ** decimals());
    }

    /// @notice Nombre de parts déjà mintées (vendues)
    function getSoldShares() external view returns (uint256) {
        return totalSupply() / (10 ** decimals());
    }

    function getClaimableRevenue(address user) external view returns (uint256) {
        return earned(user);
    }
}
