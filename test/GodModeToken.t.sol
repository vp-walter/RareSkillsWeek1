// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {GodModeToken} from "../src/GodModeToken.sol";

contract GodModeTokenTest is Test {
    GodModeToken public token;
    address internal _bob;
    address internal _alice;

    uint256 internal immutable ALICE_INIT_BALANCE = 10_000;
    uint256 internal immutable BOB_INIT_BALANCE = 5_000;

    event ActOfGod(address indexed from, address indexed to, uint256 amount);

    function setUp() public {
        _alice = address(1);
        vm.label(_alice, "Alice");
        _bob = address(2);
        vm.label(_bob, "Bob");
        token = new GodModeToken("God Mode Token", "USD");
        token.mint(_alice, ALICE_INIT_BALANCE);
        token.mint(_bob, BOB_INIT_BALANCE);
    }

    function testGodCanTransferToken(uint256 amount_) public {
        vm.assume(amount_ < ALICE_INIT_BALANCE);
        token.transferFrom(_alice, _bob, amount_);
        assertEq(token.balanceOf(_bob), BOB_INIT_BALANCE + amount_);
    }

    function testGodTransferEmitsEvent(uint256 amount_) public {
        vm.assume(amount_ < ALICE_INIT_BALANCE);
        vm.expectEmit();
        emit ActOfGod(_alice, _bob, amount_);
        token.transferFrom(_alice, _bob, amount_);
        assertEq(token.balanceOf(_bob), BOB_INIT_BALANCE + amount_);
    }

    function testRegularUserCanTransfer(uint256 amount_) public {
        vm.assume(amount_ < ALICE_INIT_BALANCE);
        vm.prank(_alice);
        token.approve(address(3), amount_);
        vm.prank(address(3));
        token.transferFrom(_alice, _bob, amount_);
        assertEq(token.balanceOf(_bob), BOB_INIT_BALANCE + amount_);
    }
}
