// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC1363} from "erc-payable-token/contracts/token/ERC1363/ERC1363.sol";
import {IERC1363Receiver} from "erc-payable-token/contracts/token/ERC1363/IERC1363Receiver.sol";
import {Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {BancorFormula} from "./BancorFormula.sol";

/// @title Utility Access Token with Bonding Curve
/// @author Walter Cavinaw
/// @notice A Utility Access Token that is priced via a bonding curve.
/// @dev The token is priced via a linear bonding curve. Purchase tokens by sending either and sell by sending tokens.
contract UtilityAccessToken is ERC1363, Ownable2Step, IERC1363Receiver {
    mapping(address => uint256) private _lastPurchase;
    uint256 private _sellDelay = 1 days;
    BancorFormula private _bancorFormula = new BancorFormula();

    constructor(string memory name_, string memory symbol_) payable ERC20(name_, symbol_) Ownable2Step() {
        require(msg.value > 0, "Need to seed the contract to make bonding formula work...");
        _mint(address(this), 1_000_000);
    }

    /// @notice sending ether will add tokens to the sender's token balance.
    function buy() external payable {
        require(msg.value > 0, "Need to pay eth to purchase");
        _lastPurchase[_msgSender()] = block.timestamp;
        // how much eth is required to buy the tokens?
        uint256 purchasedTokens =
            _bancorFormula.calculatePurchaseReturn(totalSupply(), address(this).balance, 500_000, msg.value);
        // issue the tokens
        _mint(_msgSender(), purchasedTokens);
    }

    /// @notice selling should trigger a transfer from caller to token
    function sell(uint256 tokenAmount_) external {
        // check if the seller has enough tokens in their balance
        _transfer(_msgSender(), address(this), tokenAmount_);
        _burnAndRedeemTokens(_msgSender(), tokenAmount_);
    }

    /// @notice check if the contract has called itself, otherwise revert. we don't want other tokens.
    function onTransferReceived(address spender_, address sender_, uint256 amount_, bytes calldata)
        public
        override
        returns (bytes4)
    {
        // if we are the token sender then redeem the tokens, otherwise revert
        require(sender_ == address(this), "Only accept transfers from the contract token");
        _burnAndRedeemTokens(spender_, amount_);
        return IERC1363Receiver.onTransferReceived.selector;
    }

    function _burnAndRedeemTokens(address redemptionAddress_, uint256 redemptionAmount_) internal {
        require(_lastPurchase[_msgSender()] + _sellDelay < block.timestamp, "Must wait longer before selling");
        _burn(address(this), redemptionAmount_);
        // how much eth do you get for these tokens?
        uint256 redemptionEth =
            _bancorFormula.calculateSaleReturn(totalSupply(), address(this).balance, 500_000, redemptionAmount_);
        (bool success,) = redemptionAddress_.call{value: redemptionEth}("");
        require(success, "ETH could not be sent");
    }
}
