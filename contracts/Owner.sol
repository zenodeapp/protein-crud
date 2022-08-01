pragma solidity ^0.8.9;

//SPDX-License-Identifier: UNLICENSED
contract Owner {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner is allowed to do this.");
        _;
    }

    modifier onlyBy(address _account) {
        require(msg.sender == _account, "Sender not authorized.");
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
}