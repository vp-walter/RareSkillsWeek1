// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {UtilityAccessToken} from "../src/BondingCurve/UtilityAccessToken.sol";

contract UtilityAccessTokenTest is Test {
    UtilityAccessToken public token;
    address internal _bob;
    address internal _alice;

    uint256 internal constant ALICE_INIT_BALANCE = 1e9;
    uint256 internal constant BOB_INIT_BALANCE = 1e9;

    function setUp() public {
        _alice = address(1);
        vm.label(_alice, "Alice");
        _bob = address(2);
        vm.label(_bob, "Bob");
        vm.deal(address(this), 1e6);
        token = new UtilityAccessToken{value: 1e6}("Utility Access Token", "MEMB");
        vm.deal(_alice, 1e9);
        vm.deal(_bob, 1e9);
    }

    function testCanPurchase(uint256 amount_) public {
        vm.assume(amount_ < ALICE_INIT_BALANCE);
        vm.assume(amount_ > 1e3);
        vm.prank(_alice);
        token.buy{value: amount_}();
        assertGt(token.balanceOf(_alice), 0);
    }

    function testSellFailsRightAfterPurchase() public {
        vm.prank(_alice);
        token.buy{value: 1e6}();
        uint256 aliceTokenBalance = token.balanceOf(_alice);
        assertGt(aliceTokenBalance, 0);
        vm.prank(_alice);
        vm.expectRevert();
        token.sell(aliceTokenBalance);
    }

    function testSellTokenAfterThreeDays() public {
        vm.prank(_alice);
        token.buy{value: 1e6}();
        uint256 aliceTokenBalance = token.balanceOf(_alice);
        assertGt(aliceTokenBalance, 0);
        vm.warp(2 days);
        vm.prank(_alice);
        token.sell(aliceTokenBalance);
        assertEq(token.balanceOf(_alice), 0);
    }

    function testSellViaTokenTransfer() public {
        vm.prank(_alice);
        token.buy{value: 1e6}();
        uint256 aliceTokenBalance = token.balanceOf(_alice);
        assertGt(aliceTokenBalance, 0);
        vm.warp(2 days);
        vm.prank(_alice);
        token.transfer(address(this), aliceTokenBalance);
        assertEq(token.balanceOf(_alice), 0);
    }

    function testCanTransferToken(uint256 amount_) public {
        vm.prank(_alice);
        token.buy{value: ALICE_INIT_BALANCE}();
        vm.assume(amount_ < token.balanceOf(_alice));
        vm.prank(_alice);
        token.transfer(_bob, amount_);
        assertEq(token.balanceOf(_bob), amount_);
    }
}
