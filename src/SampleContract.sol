// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {console} from "forge-std/Test.sol";

import "./Errors.sol";

library PriceConverter {
    function getPriceOfUsd(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // 1 USD = 1XXXXXXXX ETH
        return uint256(answer * 1e10);
    }

    function usdToEth(uint256 usdAmount, AggregatorV3Interface priceFeed) internal view returns(uint256) {
        uint256 priceOfUsd = getPriceOfUsd(priceFeed);
        uint256 ethAmount = usdAmount * priceOfUsd;
        return ethAmount;
    }
}

contract SampleContract {
    using PriceConverter for uint256;


    address public immutable i_owner;
    AggregatorV3Interface s_priceFeed;

    uint256 public total_funds;
    uint256 constant MIN_USD = 5;
    
    modifier onlyOwner {
        if (msg.sender != i_owner) 
            revert NotOwner();
        _;
    }

    constructor(AggregatorV3Interface priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = priceFeed;
    }

    function deposit() public payable {
        uint256 minimumEth = MIN_USD.usdToEth(s_priceFeed);
        if (!(msg.value >= minimumEth)) {
            revert InsufficientDeposit({deposit: msg.value, minimum: minimumEth});
        }

        total_funds += msg.value;
    }

    function withdraw() public onlyOwner {
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function getPriceFeed() view public returns(AggregatorV3Interface) {
        return s_priceFeed;
    }

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }
}