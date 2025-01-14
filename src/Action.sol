// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Action is ERC20{

    uint256 public immutable MAX_SUPPLY;
    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC20(_name,_symbol){
        MAX_SUPPLY = _maxSupply;
    }

}
