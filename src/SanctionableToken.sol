// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/// @title Token that can prevent addresses from sending/receiving via sanctions.
/// @author Walter Cavinaw
/// @notice The owner of the Token can add and remove addresses that won't be able to send/receive funds.
/// @dev Overrides the _beforeTokenTransfer to check for sanctioned addresses. zero address can't be sanctioned.
contract SanctionableToken is ERC20, Ownable2Step {
    mapping(address => bool) _sanctionedAddresses;

    /// @dev Zero address cannot be sanctioned, otherwise mint and burn operations break.
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) Ownable2Step() {}

    /// @notice Mint SanctionableTokens
    /// @dev reverts if the address to mint to is sanctioned.
    /// @param to_ The address of the token receiver.
    /// @param amount_ The amount of ERC20 tokens to mint.
    function mint(address to_, uint256 amount_) public onlyOwner {
        _mint(to_, amount_);
    }

    /// @notice Allows owner to add address to sanctions list
    /// @dev only the owner of the token can add an address.
    /// @dev reverts if the address is the zero address.
    /// @param addressToSanction_ The address to add to sanction list.
    function addAddressToSanctionsList(address addressToSanction_)
        external
        onlyOwner
        validAddress(addressToSanction_)
    {
        _sanctionedAddresses[addressToSanction_] = true;
    }

    /// @notice Allows owner to remove an address from sanctions list
    /// @dev only the owner of the token can add an address.
    /// @param addressToRemove_ The address to remove from sanction list.
    function removeAddressFromSanctionsList(address addressToRemove_) external onlyOwner {
        _sanctionedAddresses[addressToRemove_] = false;
    }

    /// @notice Checks if an address is sanctioned.
    /// @param addressToCheck_ The address for which to check sanction status.
    function isSanctioned(address addressToCheck_) public view returns (bool) {
        return _sanctionedAddresses[addressToCheck_];
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        bool isFromSanctioned = _sanctionedAddresses[from];
        bool isToSanctioned = _sanctionedAddresses[to];
        require(!(isFromSanctioned || isToSanctioned), "address used in transfer is sanctioned");
        super._beforeTokenTransfer(from, to, amount);
    }
}
