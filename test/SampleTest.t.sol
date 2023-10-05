// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "../src/Errors.sol";

import {SampleContract, PriceConverter} from "../src/SampleContract.sol";
import {DeploySampleContract, HelperConfig} from "../script/SampleScript.s.sol";

contract SampleTest is Test {
    using PriceConverter for uint256;

    uint256 mainnetFork;
    uint256 sepoliaFork;

    SampleContract mainnetContract;
    SampleContract sepoliaContract;
    SampleContract anvilContract;

    function setUp() external {
        DeploySampleContract deployAnvil = new DeploySampleContract();
        anvilContract = deployAnvil.run();
        
        mainnetFork = vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        DeploySampleContract deployMainnet = new DeploySampleContract();
        mainnetContract = deployMainnet.run();

        sepoliaFork = vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
        DeploySampleContract deploySepolia = new DeploySampleContract();
        sepoliaContract = deploySepolia.run();
    }

    function test_Deposit() public {
        anvilContract.deposit{value: uint256(6).usdToEth(anvilContract.getPriceFeed())}();

        vm.selectFork(mainnetFork);
        mainnetContract.deposit{value: uint256(6).usdToEth(mainnetContract.getPriceFeed())}();
        
        vm.selectFork(sepoliaFork);
        sepoliaContract.deposit{value:uint256(6).usdToEth(sepoliaContract.getPriceFeed())}();
    }

    function test_FailDeposit() public {
        vm.expectRevert();
        anvilContract.deposit{value: 0}();

        vm.selectFork(mainnetFork);
        vm.expectRevert();
        mainnetContract.deposit{value: 0}();
        
        vm.selectFork(sepoliaFork);
        vm.expectRevert();
        sepoliaContract.deposit{value:0}(); 
    }

    function test_Withdraw() public {
        vm.prank(anvilContract.i_owner());
        anvilContract.withdraw();

        vm.selectFork(mainnetFork);
        vm.prank(mainnetContract.i_owner());
        mainnetContract.withdraw();

        vm.selectFork(sepoliaFork);
        vm.prank(sepoliaContract.i_owner());
        sepoliaContract.withdraw();
    }

    function test_FailWithdraw() public {
        vm.expectRevert(NotOwner.selector);
        anvilContract.withdraw();

        vm.selectFork(mainnetFork);
        vm.expectRevert(NotOwner.selector);
        mainnetContract.withdraw();
        
        vm.selectFork(sepoliaFork);
        vm.expectRevert(NotOwner.selector);
        sepoliaContract.withdraw();
    }

    function test_GetPriceFeed() public {
        assertEq(address(anvilContract.getPriceFeed()), 0x41C3c259514f88211c4CA2fd805A93F8F9A57504);
        
        vm.selectFork(mainnetFork);
        assertEq(address(mainnetContract.getPriceFeed()), 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        
        vm.selectFork(sepoliaFork);
        assertEq(address(sepoliaContract.getPriceFeed()), 0x694AA1769357215DE4FAC081bf1f309aDC325306);
    }

    function test_Receive() public {
        (bool anvilSuccess, ) = payable(anvilContract).call{value: uint256(6).usdToEth(anvilContract.getPriceFeed())}("");
        assert(anvilSuccess);
        assertEq(anvilContract.total_funds(), uint256(6).usdToEth(anvilContract.getPriceFeed()));

        vm.selectFork(mainnetFork);
        (bool mainnetSuccess, ) = payable(mainnetContract).call{value: uint256(6).usdToEth(mainnetContract.getPriceFeed())}("");
        assert(mainnetSuccess);
        assertEq(mainnetContract.total_funds(), uint256(6).usdToEth(mainnetContract.getPriceFeed()));
        
        vm.selectFork(sepoliaFork);
        (bool sepoliaSuccess, ) = payable(sepoliaContract).call{value: uint256(6).usdToEth(sepoliaContract.getPriceFeed())}("");
        assert(sepoliaSuccess);
        assertEq(sepoliaContract.total_funds(), uint256(6).usdToEth(sepoliaContract.getPriceFeed()));
    }

    function test_Fallback() public {
        (bool anvilSuccess, ) = payable(anvilContract).call{value: uint256(6).usdToEth(anvilContract.getPriceFeed())}("Fallback");
        assert(anvilSuccess);
        assertEq(anvilContract.total_funds(), uint256(6).usdToEth(anvilContract.getPriceFeed()));

        vm.selectFork(mainnetFork);
        (bool mainnetSuccess, ) = payable(mainnetContract).call{value: uint256(6).usdToEth(mainnetContract.getPriceFeed())}("Fallback");
        assert(mainnetSuccess);
        assertEq(mainnetContract.total_funds(), uint256(6).usdToEth(mainnetContract.getPriceFeed()));
        
        vm.selectFork(sepoliaFork);
        (bool sepoliaSuccess, ) = payable(sepoliaContract).call{value: uint256(6).usdToEth(sepoliaContract.getPriceFeed())}("Fallback");
        assert(sepoliaSuccess);
        assertEq(sepoliaContract.total_funds(), uint256(6).usdToEth(sepoliaContract.getPriceFeed()));
    }
}