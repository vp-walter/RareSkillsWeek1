// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {UntrustedEscrow} from "../src/UntrustedEscrow.sol";
import {GodModeToken} from "../src/GodModeToken.sol";

contract UntrustedEscrowTest is Test {
    UntrustedEscrow public escrow;
    GodModeToken public token;
    address internal _bob;
    address internal _alice;

    uint256 internal constant ALICE_INIT_BALANCE = 10_000;
    uint256 internal constant BOB_INIT_BALANCE = 5_000;

    function setUp() public {
        _alice = address(1);
        vm.label(_alice, "Alice");
        _bob = address(2);
        vm.label(_bob, "Bob");
        token = new GodModeToken("God Mode Token", "USD");
        token.mint(_alice, ALICE_INIT_BALANCE);
        token.mint(_bob, BOB_INIT_BALANCE);
        escrow = new UntrustedEscrow();
    }

    function testCreateTransaction(uint256 amount_) public {
        vm.assume(amount_ < ALICE_INIT_BALANCE);
        vm.assume(amount_ > 0);
        vm.prank(_alice);
        token.approve(address(escrow), amount_);
        vm.prank(_alice);
        uint256 txId = escrow.openTx(_alice, _bob, token, amount_);
        assertEq(txId, 0);
        assertEq(token.balanceOf(_alice), ALICE_INIT_BALANCE - amount_);
    }

    function testCreateTransactionFailsIfNotTheBuyer(uint256 amount_) public {
        vm.assume(amount_ < BOB_INIT_BALANCE);
        vm.assume(amount_ > 0);
        vm.prank(_alice);
        token.approve(address(escrow), amount_);
        vm.prank(_alice);
        vm.expectRevert();
        escrow.openTx(_bob, _alice, token, amount_);
    }

    function testSettleTransactionFailsIfTooSoon(uint256 amount_) public {
        vm.assume(amount_ < ALICE_INIT_BALANCE);
        vm.assume(amount_ > 0);
        vm.prank(_alice);
        token.approve(address(escrow), amount_);
        vm.prank(_alice);
        uint256 txId = escrow.openTx(_alice, _bob, token, amount_);
        assertEq(txId, 0);
        vm.prank(_bob);
        vm.expectRevert();
        escrow.settleTx(txId);
    }

    function testSettleTransactionAfterThreeDays(uint256 amount_) public {
        vm.assume(amount_ < ALICE_INIT_BALANCE);
        vm.assume(amount_ > 0);
        vm.prank(_alice);
        token.approve(address(escrow), amount_);
        vm.prank(_alice);
        uint256 txId = escrow.openTx(_alice, _bob, token, amount_);
        assertEq(txId, 0);
        vm.warp(4 days);
        vm.prank(_bob);
        escrow.settleTx(txId);
        assertEq(token.balanceOf(_bob), BOB_INIT_BALANCE + amount_);
    }

    function testEscrowOwnerCancelsATransaction(uint256 amount_) public {
        vm.assume(amount_ < ALICE_INIT_BALANCE);
        vm.assume(amount_ > 0);
        vm.prank(_alice);
        token.approve(address(escrow), amount_);
        vm.prank(_alice);
        uint256 txId = escrow.openTx(_alice, _bob, token, amount_);
        assertEq(txId, 0);
        escrow.cancelTx(txId);
        assertEq(token.balanceOf(_alice), ALICE_INIT_BALANCE);
    }
}
