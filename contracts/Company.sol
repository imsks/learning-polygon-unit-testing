// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Company {
    // 1. Variables
    // Address of the master
    address public master;

    // List of all the owners
    address[] public owners;

    // Mapping to keep track of all the owners
    mapping(address => bool) isOwner;

    // Mapping of shares owned by shareholders
    mapping(address => uint256) share;

    // 2. Events
    // When Master is setup
    event MasterSetup(address indexed master);

    // When an owner is added by master
    event OwnerAddition(address indexed owner);

    // When shares are transferred between shareholders
    event Transfer(address indexed receiver, uint256 amount);

    // When an owner is removed
    event OwnerRemoval(address indexed owner);

    // 3. Modifiers
    // Checks if the sender is master
    modifier onlyMaster() {
        require(msg.sender == address(master));
        _;
    }

    // Checks if the sender is owner
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Only owners can call.");
        _;
    }

    // Checks if the sender is admin
    modifier onlyAdmins() {
        require(
            isOwner[msg.sender] || msg.sender == address(master),
            "Only master or owners can call."
        );
        _;
    }
}
