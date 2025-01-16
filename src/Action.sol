// SPDX-License-Identifier: MIT

pragma solidity ^0.8.27;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Action is ERC20 {
    uint256 public immutable MAX_SUPPLY;
    uint256 public constant PRICE = 0.001 ether;

    error MAX_SUPPLY_HIT();
    error INSUFFICIENT_FUNDS();

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC20(_name, _symbol) {
        MAX_SUPPLY = _maxSupply * 10 ** decimals();
    }

    modifier _hitSupply(uint256 _amount) {
        if (MAX_SUPPLY == totalSupply() || totalSupply() + _amount > MAX_SUPPLY) {
            revert MAX_SUPPLY_HIT();
        }
        _;
    }

    function mint() public payable _hitSupply(msg.value) returns (uint256) {
        require(msg.value > 0, INSUFFICIENT_FUNDS());
        uint256 amount = msg.value / PRICE;
        _mint(msg.sender, amount);
        return amount;
    }
}

/*

+-------------------------------+
|   0.001 ether   |   1 ether   |   f(x) = x / 0.001 ether
|     1 token     |  1k tokens  |
+-------------------------------+

*/
