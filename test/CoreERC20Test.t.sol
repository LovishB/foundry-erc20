// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {CoreERC20} from "../src/CoreERC20.sol";
import {DeployCoreERC20} from "../script/DeployCoreERC20.s.sol";


contract CoreERC20Test is Test {
    CoreERC20 coreERC20;
    DeployCoreERC20 deployCoreERC20;
    address owner;
    address recipient;
    address spender;

    function setUp() external {
        deployCoreERC20 = new DeployCoreERC20();
        coreERC20 = deployCoreERC20.run();

        owner = msg.sender;
        recipient = makeAddr("recipient");
        spender = makeAddr("spender");
    }

    function testInitialState() public view {
        assertEq(coreERC20.name(), deployCoreERC20.NAME());
        assertEq(coreERC20.symbol(), deployCoreERC20.SYMBOL());
        assertEq(coreERC20.decimals(), deployCoreERC20.DECIMALS());
        assertEq(coreERC20.totalSupply(), deployCoreERC20.TOTAL_SUPPLY());
        //balance check for owner
        assertEq(coreERC20.balanceOf(owner), deployCoreERC20.TOTAL_SUPPLY());
    }

    function testMintingErrorDecimalsTooHigh() public {
        vm.expectRevert();
        new CoreERC20("Test", "TEST", 19, 1000);
    }

    function testMintingErrorInvalidSupply() public {
        vm.expectRevert();
        new CoreERC20("Test", "TEST", 19, 10000000000000);
    }

    function testTransfer() public {
        uint256 transferAmt = 100;
        vm.prank(owner);
        bool success = coreERC20.transfer(recipient, transferAmt);

        assertTrue(success);
        assertEq(coreERC20.balanceOf(owner), deployCoreERC20.TOTAL_SUPPLY()-transferAmt);
        assertEq(coreERC20.balanceOf(recipient), transferAmt);
    }

    function testTransferEvent() public {
        uint256 transferAmt = 100;
        vm.expectEmit(true, true, false, true);
        emit CoreERC20.Transfer(owner, recipient, transferAmt);
        vm.prank(owner);
        coreERC20.transfer(recipient, transferAmt);
    }

    function testApprove() public {
        uint256 approveAmt = 100;
        vm.prank(owner);
        bool success = coreERC20.approve(spender, approveAmt);
        assertTrue(success);
        assertEq(coreERC20.allowance(owner, spender), approveAmt);
    }

    function testApproveEvent() public {
        uint256 transferAmt = 100;
        vm.expectEmit(true, true, false, true);
        emit CoreERC20.Approval(owner, spender, transferAmt);
        vm.prank(owner);
        coreERC20.approve(spender, transferAmt);
    }

    function testTransferFrom() public {
        uint256 transferAmt = 100;
        uint256 approveAmt = 100;
        vm.prank(owner);
        coreERC20.approve(spender, approveAmt);
        vm.prank(spender);
        bool success = coreERC20.transferFrom(owner, recipient, transferAmt);
        assertTrue(success);
        assertEq(coreERC20.balanceOf(owner), deployCoreERC20.TOTAL_SUPPLY()-transferAmt);
        assertEq(coreERC20.balanceOf(recipient), transferAmt);
        assertEq(coreERC20.allowance(owner, spender), approveAmt-transferAmt);
    }


}