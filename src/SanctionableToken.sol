// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

// @notice:
contract SanctionableToken is ERC20, Ownable2Step {
    mapping(address => bool) _sanctionedAddresses;

    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) Ownable2Step() {}

    function addAddressToSanctionsList(address addressToSanction_)
        external
        payable
        onlyOwner
        validAddress(addressToSanction_)
    {
        _sanctionedAddresses[addressToSanction_] = true;
    }

    function removeAddressFromSanctionsList(address addressToRemove_)
        external
        payable
        onlyOwner
        validAddress(addressToRemove_)
    {
        _sanctionedAddresses[addressToRemove_] = false;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {
        bool isFromSanctioned = _sanctionedAddresses[from];
        bool isToSanctioned = _sanctionedAddresses[to];
        require(isFromSanctioned || isToSanctioned, "address used in transfer is sanctioned");
        super._beforeTokenTransfer(from, to, amount);
    }
}
