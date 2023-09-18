// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable2Step} from "openzeppelin-contracts/contracts/access/Ownable2Step.sol";

/// @title Escrow Service for ERC20 Tokens
/// @author Walter Cavinaw
/// @notice An escrow service that takes arbitrary ERC20 Tokens to settle transactions betwen buyers and sellers.
/// @dev When new transactions are created the user is given a transactionId to keep track of.
contract UntrustedEscrow is Ownable2Step {
    using SafeERC20 for IERC20;

    struct Tx {
        uint256 txId;
        address buyer;
        address seller;
        IERC20 token;
        uint256 deposit;
        uint256 timestamp;
    }

    uint256 private _txIdCounter;
    mapping(uint256 => Tx) private _txMap;

    event TransactionOpened(uint256 indexed txId, address indexed buyer, address indexed seller);
    event TransactionSettled(uint256 indexed txId, address indexed buyer, address indexed seller);
    event TransactionCancelled(uint256 indexed txId, address indexed buyer, address indexed seller);

    constructor() Ownable2Step() {}

    /// @notice the buyer can initiate a transaction and redeem their tokens.
    /// @param buyer_ The buyer who initially deposits a token amount
    /// @param seller_ The seller who eventually receives the amount.
    /// @param token_ The token that is being deposited.
    /// @param depositAmount_ The amount of the token that is deposited.
    function openTx(address buyer_, address seller_, IERC20 token_, uint256 depositAmount_)
        external
        returns (uint256)
    {
        require(_msgSender() == buyer_, "Only a buyer can initiate a transaction");
        Tx memory txToInitiate = Tx(_txIdCounter, buyer_, seller_, token_, depositAmount_, block.timestamp);
        _txMap[_txIdCounter] = txToInitiate;

        token_.safeTransferFrom(buyer_, address(this), depositAmount_);
        emit TransactionOpened(txToInitiate.txId, buyer_, seller_);

        _txIdCounter = _txIdCounter + 1;

        return txToInitiate.txId;
    }

    /// @notice the seller can settle a transaction and redeem their tokens.
    /// @param txId The ID of the transaction to settle.
    function settleTx(uint256 txId) external {
        Tx memory txToClose = _txMap[txId];

        require(_msgSender() == txToClose.seller, "Only the seller can withdraw escrowed tokens");
        require(block.timestamp > txToClose.timestamp + 3 days, "Can only withdraw tokens after 3 days");

        txToClose.token.safeTransfer(txToClose.seller, txToClose.deposit);
        emit TransactionSettled(txToClose.txId, txToClose.buyer, txToClose.seller);

        delete _txMap[txId];
    }

    /// @notice the Escrow owner can cancel a transaction (e.g. due to external events)
    /// @param txId The ID of the transaction to cancel.
    function cancelTx(uint256 txId) external onlyOwner {
        Tx memory txToCancel = _txMap[txId];

        txToCancel.token.safeTransfer(txToCancel.buyer, txToCancel.deposit);
        emit TransactionCancelled(txToCancel.txId, txToCancel.buyer, txToCancel.seller);

        delete _txMap[txId];
    }
}
