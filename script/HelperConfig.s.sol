// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/Test.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";


contract HelperConfig is Script {
    struct NetworkConfig {
        AggregatorV3Interface priceFeed;
    }
    
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 1;

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        }
        else if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else {
           activeNetworkConfig = getAnvilEthConfig();
        }
    }

    function getActivePriceFeed() public view returns (AggregatorV3Interface) {
        return activeNetworkConfig.priceFeed;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory ethereumConfig = NetworkConfig({
            priceFeed: AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419)
        });

        return ethereumConfig;
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306)
        });

        return sepoliaConfig;
    }

    function getAnvilEthConfig() public returns (NetworkConfig memory) {
        if (address(activeNetworkConfig.priceFeed) != address(0)) {
            return activeNetworkConfig;
        }
        //vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        //vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: AggregatorV3Interface(address(mockPriceFeed))
        });

        return anvilConfig;
    }
}