// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Property is ERC721 {
    
    string public name;
    string public symbol;
    uint256 totalShares; 
}