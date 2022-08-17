// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import { Test } from "forge-std/Test.sol";
import { console2 } from "forge-std/console2.sol";
import { MittenLink } from "src/MittenLink.sol";

contract MittenLinkTest is Test {
    MittenLink public mittenLinkToTest;

    function setUp() public {
        mittenLinkToTest = new MittenLink();
    }

    function testGetTransferValue () public {
        console2.log("Running getTransferValue");
        assertEq(
            mittenLinkToTest.getTransferValue(0xB88706678cb37683C64cBBA2074d154af602B522),
            361800000000000,
            "0xB887... should be a value rounded to 1e10"
        );

        assertEq(
            mittenLinkToTest.getTransferValue(0x2Db1D8CdF1Abe8C70b531a790CDf2FF38aecF652),
            93350000000000,
            "0x2Db1... should be a value rounded to 1e10"
        );

        assertEq(
            mittenLinkToTest.getTransferValue(0x890EaCEB4eE2e893f9155Ddf45887885Ba7963f5),
            270010000000000,
            "0x890E... should be a value rounded to 1e10"
        );

        assertEq(
            mittenLinkToTest.getTransferValue(0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567),
            94650000000000,
            "0x2E5d... should be a value rounded to 1e10"
        );

        assertEq(
            mittenLinkToTest.getTransferValue(0x0000000000000000000000000000000000000000),
            5000000000000,
            "0x0000... should have transfer value match min transfer"
        );

        assertEq(
            mittenLinkToTest.getTransferValue(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF),
            500000000000000,
            "0xFFfF... should have value match max transfer"
        );
    }

    function testLinkWallets () public {
        vm.prank(0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567);
        try mittenLinkToTest.linkWallets(
            0x890EaCEB4eE2e893f9155Ddf45887885Ba7963f5,
            0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567,
            hex"02ed0403848da68320848da6833a825208942e5deb91b444efbea95e34bfb9aa043a5f99f5678656156ba0c40080c0",
            27,
            0x45fef98df3f09150c788ad8ac6cf04ade04c6666d45fc77617d9cf68e5808f33,
            0x0e75977861e736be01d0af5a7c8d518250bfbed7176c6a7848b6435b7f4902ad
        ) {
            console2.log("linkWallets ok");
        } catch Error(string memory) {
            assertTrue(false, "failed with reason");
        } catch (bytes memory) {
            assertTrue(false, "failed unexpected");
        }

        address[] memory walletLinks = mittenLinkToTest.getWalletLinks(0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567);

        assertEq(walletLinks.length, 1, "Wallet links should have 1 address exactly");

        assertEq(walletLinks[0], 0x890EaCEB4eE2e893f9155Ddf45887885Ba7963f5, "Wallet link does not match expected address");

        vm.prank(0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567);
        mittenLinkToTest.removeLink(
            0x890EaCEB4eE2e893f9155Ddf45887885Ba7963f5,
            0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567
        );

        address[] memory walletLinks2 = mittenLinkToTest.getWalletLinks(0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567);

        assertEq(walletLinks2.length, 0, "Wallet links should be empty");
    }
}