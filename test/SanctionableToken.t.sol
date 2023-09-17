// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
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
    }

    function testTokenName() public {
        assertEq(token.name(), "USD");
    }

    function testCanTransferFunds() public {}

    function testAdminCanSanctionAddress() public {}

    function testNonAdminCannotSanctionAddress() public {}

    function testSanctionedAddressCantTransferFunds() public {}

    function testSanctionedAddressCantReceiveFunds() public {}

    function testCantSanctionZeroAddress() public {}

    function testSanctionedAddressCantTransferFrom() public {}

    function testRemoveSanctionedAddressCanTransfer() public {}
}
