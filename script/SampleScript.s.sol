// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";

import {HelperConfig} from "./HelperConfig.s.sol";
import {SampleContract} from "../src/SampleContract.sol";



contract DeploySampleContract is Script {

    function run() external returns(SampleContract) {
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        SampleContract mContract = new SampleContract(ethUsdPriceFeed);
        vm.stopBroadcast();
        return mContract;
    }

}