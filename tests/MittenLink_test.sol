// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "remix_tests.sol"; // this import is automatically injected by Remix.
import "hardhat/console.sol";
import "../contracts/MittenLink.sol";

contract MittenLinkTest {
    MittenLink mittenLinkToTest;

    function beforeAll () public {
        mittenLinkToTest = new MittenLink();
    }

    function getTransferValue () public {
        console.log("Running getTransferValue");
        Assert.equal(
            mittenLinkToTest.getTransferValue(0xB88706678cb37683C64cBBA2074d154af602B522),
            361800000000000,
            "0xB887... should be a value rounded to 1e10"
        );

        Assert.equal(
            mittenLinkToTest.getTransferValue(0x2Db1D8CdF1Abe8C70b531a790CDf2FF38aecF652),
            93350000000000,
            "0x2Db1... should be a value rounded to 1e10"
        );

        Assert.equal(
            mittenLinkToTest.getTransferValue(0x890EaCEB4eE2e893f9155Ddf45887885Ba7963f5),
            270010000000000,
            "0x890E... should be a value rounded to 1e10"
        );

        Assert.equal(
            mittenLinkToTest.getTransferValue(0x2E5deB91b444EfbeA95E34BFb9aA043A5F99f567),
            94650000000000,
            "0x2E5d... should be a value rounded to 1e10"
        );

        Assert.equal(
            mittenLinkToTest.getTransferValue(0x0000000000000000000000000000000000000000),
            5000000000000,
            "0x0000... should have transfer value match min transfer"
        );

        Assert.equal(
            mittenLinkToTest.getTransferValue(0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF),
            500000000000000,
            "0xFFfF... should have value match max transfer"
        );
    }
}