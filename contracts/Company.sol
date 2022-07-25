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

    // Contructor sets the master address of Company contract
    constructor(address _master) {
        require(_master != address(0), "Master address cannot be a zero");
        master = _master;
        share[master] = 10000000;
    }

    // Returns the address of the master
    function getMaster() public view returns (address) {
        return master;
    }

    // Returns the list of all owners
    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    // Check if a given address is owner or not
    function checkIfOwner(address owner) public view returns (bool) {
        return isOwner[owner];
    }

    // Add a new owner
    function addOwner(address owner) public onlyMaster {
        isOwner[owner] = true;
        owners.push(owner);
        share[owner] = 10000000;

        emit OwnerAddition(owner);
    }

    // Remove an owner
    function removeOwner(address owner) public onlyMaster {
        require(isOwner[owner]);
        isOwner[owner] = false;

        for (uint256 i = 0; i < owners.length - 1; i++) {
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        }

        owners.pop();

        emit OwnerRemoval(owner);
    }

    // Transfer share
    function giveShare(address receiver, uint256 _share) public onlyAdmins {
        require(
            share[msg.sender] >= _share,
            "Share exceeds the sender's limit"
        );

        share[msg.sender] = share[msg.sender] - _share;
        share[receiver] += _share;

        emit Transfer(receiver, _share);
    }

    // Add share to any of the owners
    function addShare(address receiver, uint256 _share) public onlyAdmins {
        // 1. Check if receiver address is correct
        require(isOwner[receiver], "Only an owner can receive");

        // 2. Check if address is not by master
        require(
            address(receiver) != address(master),
            "Can't tranfer to master"
        );

        // 3. Transfer share
        require(
            share[msg.sender] >= _share,
            "Share exceeds the sender's limit"
        );

        share[receiver] += _share;

        emit Transfer(receiver, _share);
    }
}
