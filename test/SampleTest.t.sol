// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

import {SampleContract} from "../src/SampleContract.sol";
import {DeploySampleContract} from "../script/SampleScript.s.sol";

contract SampleTest is Test {
    SampleContract sampleContract;

    function setUp() external {
        DeploySampleContract deploy = new DeploySampleContract();
        sampleContract = deploy.run();
    }

}