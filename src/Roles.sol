// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library Roles {
    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 public constant YIELD_MANAGER_ROLE = keccak256("YIELD_MANAGER_ROLE");
    bytes32 public constant PROPERTY_MANAGER_ROLE = keccak256("PROPERTY_MANAGER_ROLE");
}
