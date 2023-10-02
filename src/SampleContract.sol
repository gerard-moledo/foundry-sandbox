// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

error NotOwner();

library PriceConverter {
    function getPriceOfUsd() internal view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // 1 USD = 1XXXXXXXX ETH
        return uint256(answer * 1e10);
    }

    function usdToEth(uint256 usdAmount) internal view returns(uint256) {
        uint256 priceOfUsd = getPriceOfUsd();
        uint256 ethAmount = usdAmount * priceOfUsd;
        return ethAmount;
    }
}

contract SampleContract {
    using PriceConverter for uint256;

    address public immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    uint256 public total_funds;
    uint256 constant MIN_USD = 5;
    
    modifier onlyOwner {
        if (msg.sender != i_owner) revert NotOwner();
        _;
    }

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function getVersion() view public returns(uint256) {
        return s_priceFeed.version();
    }

    function deposit() public payable {
        require(msg.value >= MIN_USD.usdToEth(), "Must spend at least 5 USD");

        total_funds += msg.value;
    }

    function withdraw() public onlyOwner {
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    receive() external payable {
        deposit();
    }

    fallback() external payable {
        deposit();
    }
}