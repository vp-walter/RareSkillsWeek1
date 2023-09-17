// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SanctionableToken} from "../src/SanctionableToken.sol";

contract SanctionableTokenTest is Test {
    SanctionableToken public token;
    address internal _bob;
    address internal _alice;

    function setUp() public {
        _alice = address(1);
        vm.label(_alice, "Alice");
        _bob = address(2);
        vm.label(_bob, "Bob");
        token = new SanctionableToken("USD", "USD");
        token.mint(_alice, 10_000);
        token.mint(_bob, 5_000);
    }

    function testCanTransferFunds() public {
        vm.prank(_alice);
        token.transfer(_bob, 100);
        assertEq(token.balanceOf(_bob), 5_100);
    }

    function testAdminCanSanctionAddress() public {
        token.addAddressToSanctionsList(_bob);
        assertEq(token.isSanctioned(_bob), true);
    }

    function testNonAdminCannotSanctionAddress() public {
        vm.prank(_alice);
        vm.expectRevert();
        token.addAddressToSanctionsList(_bob);
    }

    function testSanctionedAddressCantTransferFunds() public {
        token.addAddressToSanctionsList(_bob);
        assertEq(token.isSanctioned(_bob), true);
        vm.prank(_bob);
        vm.expectRevert();
        token.transfer(_alice, 100);
    }

    function testSanctionedAddressCantReceiveFunds() public {
        token.addAddressToSanctionsList(_bob);
        assertEq(token.isSanctioned(_bob), true);
        vm.prank(_alice);
        vm.expectRevert();
        token.transfer(_bob, 100);
    }

    // can't sanction zero address because it's used in minting and burning
    function testCantSanctionZeroAddress() public {
        vm.expectRevert();
        token.addAddressToSanctionsList(address(0));
    }

    function testSanctionedAddressCantTransferFrom() public {
        token.addAddressToSanctionsList(_bob);
        assertEq(token.isSanctioned(_bob), true);
        vm.prank(_alice);
        token.approve(address(3), 100);
        assertEq(token.allowance(_alice, address(3)), 100);
        vm.prank(address(3));
        vm.expectRevert();
        token.transferFrom(_alice, _bob, 100);
    }

    function testRemoveSanctionedAddressCanTransfer() public {
        token.addAddressToSanctionsList(_bob);
        assertEq(token.isSanctioned(_bob), true);
        vm.prank(_alice);
        token.approve(address(3), 100);
        assertEq(token.allowance(_alice, address(3)), 100);
        vm.prank(address(3));
        vm.expectRevert();
        token.transferFrom(_alice, _bob, 100);
        token.removeAddressFromSanctionsList(_bob);
        vm.prank(address(3));
        token.transferFrom(_alice, _bob, 100);
        assertEq(token.balanceOf(_bob), 5_100);
    }
}
