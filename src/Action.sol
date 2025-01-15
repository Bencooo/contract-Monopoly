// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ERC20} from '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Action is ERC20{

    uint256 public immutable MAX_SUPPLY;

    error MAX_SUPPLY_HIT();

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC20(_name,_symbol){
        MAX_SUPPLY = _maxSupply * 10** decimals();
        _mint(address(this),MAX_SUPPLY);
    }

    modifier _hitSupply(uint256 _amount) {
        if(MAX_SUPPLY == totalSupply() || totalSupply() + _amount > MAX_SUPPLY) {
            revert MAX_SUPPLY_HIT();
        }
        _;
    }

    function mint(uint256 _amount) _hitSupply(_amount) public {
        _mint(msg.sender,_amount);
    }

}
