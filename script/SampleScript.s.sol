// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {console} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";

import {HelperConfig} from "./HelperConfig.s.sol";
import {SampleContract} from "../src/SampleContract.sol";



contract DeploySampleContract is Script {

    function run() external returns(SampleContract) {
        HelperConfig helperConfig = new HelperConfig();
        AggregatorV3Interface ethUsdPriceFeed = helperConfig.getActivePriceFeed();
        
        vm.startBroadcast();
        SampleContract mContract = new SampleContract(ethUsdPriceFeed);
        vm.stopBroadcast();
        
        return mContract;
    }

}