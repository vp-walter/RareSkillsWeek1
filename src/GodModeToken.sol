// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/// @title Token with God Mode
/// @author Walter Cavinaw
/// @notice A special address can transfer between accounts at will.
/// @dev The owner of the token can transfer between any accounts and emits an ActOfGod.
contract GodModeToken is ERC20, Ownable2Step {
    event ActOfGod(address indexed from, address indexed to, uint256 amount);

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) Ownable2Step() {}

    /// @notice Mint GodModeTokens
    /// @param to_ The address of the token receiver.
    /// @param amount_ The amount of ERC20 tokens to mint.
    function mint(address to_, uint256 amount_) public onlyOwner {
        _mint(to_, amount_);
    }

    /// @notice Extends tranferFrom to allow owner to transfer at will.
    /// @dev A transfer by god will emit an ActOfGod event.
    /// @param from_ The address from which to take tokens.
    /// @param to_ The address of the token receiver.
    /// @param amount_ The amount of ERC20 tokens to transfer.
    function transferFrom(address from_, address to_, uint256 amount_) public override returns (bool) {
        if (_msgSender() == owner()) {
            _transfer(from_, to_, amount_);
            emit ActOfGod(from_, to_, amount_);
            return true;
        } else {
            return super.transferFrom(from_, to_, amount_);
        }
    }
}
