// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";

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
        anvilContract.deposit{value: 1e25}();

        vm.selectFork(mainnetFork);
        mainnetContract.deposit{value: 1e25}();
        
        vm.selectFork(sepoliaFork);
        sepoliaContract.deposit{value:1e25}();
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


}