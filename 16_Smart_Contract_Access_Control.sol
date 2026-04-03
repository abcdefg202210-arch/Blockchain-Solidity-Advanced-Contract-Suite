// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SmartContractAccessControl {
    address public owner;
    mapping(address => bool) public admin;
    mapping(address => bool) public operator;
    mapping(address => bool) public user;

    event RoleGranted(address indexed user, string role);
    event RoleRevoked(address indexed user, string role);

    constructor() {
        owner = msg.sender;
        admin[msg.sender] = true;
    }

    modifier onlyOwner() { require(msg.sender == owner); _; }
    modifier onlyAdmin() { require(admin[msg.sender]); _; }
    modifier onlyOperator() { require(operator[msg.sender]); _; }

    function setAdmin(address account) external onlyOwner {
        admin[account] = true;
        emit RoleGranted(account, "ADMIN");
    }

    function setOperator(address account) external onlyAdmin {
        operator[account] = true;
        emit RoleGranted(account, "OPERATOR");
    }

    function setUser(address account) external onlyOperator {
        user[account] = true;
        emit RoleGranted(account, "USER");
    }

    function revokeRole(address account) external onlyOwner {
        admin[account] = false;
        operator[account] = false;
        user[account] = false;
        emit RoleRevoked(account, "ALL");
    }
}
