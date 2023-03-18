// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/*
 test command:
 forge test --via-ir --fork-url https://mainnet.infura.io/v3/7b367f3e8f1d48e5b43e1b290a1fde16
*/

import "forge-std/Test.sol";

//Frens Contracts
import "../../contracts/FrensArt.sol";
import "../../contracts/FrensMetaHelper.sol";
import "../../contracts/FrensPoolShareTokenURI.sol";
import "../../contracts/FrensStorage.sol";
import "../../contracts/StakingPool.sol";
import "../../contracts/StakingPoolFactory.sol";
import "../../contracts/FrensPoolShare.sol";
import "../../contracts/FrensOracle.sol";
import "../../contracts/interfaces/IStakingPoolFactory.sol";
import "../../contracts/interfaces/IDepositContract.sol";
import "./TestHelper.sol";


contract StakingPoolTest is Test {
    FrensArt public frensArt;
    FrensMetaHelper public frensMetaHelper;
    FrensPoolShareTokenURI public frensPoolShareTokenURI;
    FrensStorage public frensStorage;
    StakingPoolFactory public stakingPoolFactory;
    StakingPool public stakingPool;
    StakingPool public stakingPool2;
    FrensPoolShare public frensPoolShare;
    FrensOracle public frensOracle;

    //mainnet
    address payable public depCont = payable(0x00000000219ab540356cBB839Cbe05303d7705Fa);
    //goerli
    //address payable public depCont = payable(0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b);
    address public ssvRegistryAddress = 0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04;
    address public ENSAddress = 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e;

    IDepositContract depositContract = IDepositContract(depCont);

    address public contOwner = 0x0000000000000000000000000000000001111738;
    address payable public alice = payable(0x00000000000000000000000000000000000A11cE);
    address payable public bob = payable(0x0000000000000000000000000000000000000B0b);
    address payable public feeRecipient = payable(0x0000000000000000000000000694200000001337);

    bytes pubkey = hex"ac542dcb86a85a8deeef9150dbf8ad24860a066deb43b20294ed7fb65257f49899b7103c35b26289035de4227e1cc575";
    bytes withdrawal_credentials = hex"0100000000000000000000004f81992fce2e1846dd528ec0102e6ee1f61ed3e2";
    bytes signature = hex"92e3289be8c1379caae22fa1d6637c3953620db6eed35d1861b9bb9f0133be8b0cc631d16a3f034960fb826977138c59023543625ecb863cb5a748714ff5ee9f3286887e679cf251b6b0f14b190beac1ad7010cc136da6dd9e98dd4e8b7faae9";
    bytes32 deposit_data_root = 0x4093180202063b0e66cd8aef5a934bfabcf32919e494064542b5f1a3889bf516;

    function setUp() public {
      //deploy storage
      frensStorage = new FrensStorage();
      //initialise SSVRegistry
      frensStorage.setAddress(keccak256(abi.encodePacked("external.contract.address", "SSVRegistry")), ssvRegistryAddress);
      //initialise deposit Contract
      frensStorage.setAddress(keccak256(abi.encodePacked("external.contract.address", "DepositContract")), depCont);
      //initialise ENS 
      frensStorage.setAddress(keccak256(abi.encodePacked("external.contract.address", "ENS")), ENSAddress);
      //feeReceipient
      frensStorage.setAddress(keccak256(abi.encodePacked("protocol.fee.recipient")), feeRecipient);
      //deploy NFT contract
      frensPoolShare = new FrensPoolShare(frensStorage);
      //initialise NFT contract
      frensStorage.setAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolShare")), address(frensPoolShare));
      //deploy Factory
      stakingPoolFactory = new StakingPoolFactory(frensStorage);
      //initialise Factory
      frensStorage.setAddress(keccak256(abi.encodePacked("contract.address", "StakingPoolFactory")), address(stakingPoolFactory));
      frensPoolShare.grantRole(bytes32(0x00),  address(stakingPoolFactory));
      //deploy FrensOracle
      frensOracle = new FrensOracle(frensStorage);
      //initialise FrensOracle
      frensStorage.setAddress(keccak256(abi.encodePacked("contract.address", "FrensOracle")), address(frensOracle));
      //deploy MetaHelper
      frensMetaHelper = new FrensMetaHelper(frensStorage);
      //initialise Metahelper
      frensStorage.setAddress(keccak256(abi.encodePacked("contract.address", "FrensMetaHelper")), address(frensMetaHelper));
      //deploy TokenURI
      frensPoolShareTokenURI = new FrensPoolShareTokenURI(frensStorage);
      //Initialise TokenURI
      frensStorage.setAddress(keccak256(abi.encodePacked("contract.address", "FrensPoolShareTokenURI")), address(frensPoolShareTokenURI));
      //deployArt
      frensArt = new FrensArt(frensStorage);
      //initialise art
      frensStorage.setAddress(keccak256(abi.encodePacked("contract.address", "FrensOracle")), address(frensOracle));
      //set contracts as deployed
     
      //create staking pool through proxy contract
      (address pool) = stakingPoolFactory.create(contOwner, false, true, 0, 32000000000000000000);
      //connect to staking pool
      stakingPool = StakingPool(payable(pool));
      //console.log the pool address for fun  if(FrensPoolShareOld == 0){
      //console.log("pool", pool);

    }

    function testTransferLock(uint72 x) public {
      if(x > 0 && x <= 32 ether){
        startHoax(alice);
        stakingPool.depositToPool{value: x}();
        uint id = frensPoolShare.tokenOfOwnerByIndex(alice, 0);
        vm.expectRevert("not transferable");
        frensPoolShare.transferFrom(alice, bob, id);
      } else if(x == 0) {
        vm.expectRevert("must deposit ether");
        startHoax(alice);
        stakingPool.depositToPool{value: x}();
      } else {
        vm.expectRevert("total deposits cannot be more than 32 Eth");
        startHoax(alice);
        stakingPool.depositToPool{value: x}();
      }
    }

    function testRageQuitUnlock(uint32 x) public {
      uint maxUint32 = 4294967296; //added 1 for fun (really to prevent over/underflow error)
      uint aliceDeposit = (uint(x) + 1) * 31999999999999999999 / (maxUint32);
      uint bobDeposit = 32000000000000000000 - aliceDeposit;
      hoax(alice);
      stakingPool.depositToPool{value: aliceDeposit}();
      hoax(bob);
      stakingPool.depositToPool{value: bobDeposit}();
      //test transfer lock
      uint id = frensPoolShare.tokenOfOwnerByIndex(alice, 0);
      vm.expectRevert("not transferable");
      vm.prank(alice);
      frensPoolShare.transferFrom(alice, bob, id);
      //test setting price too high
      vm.prank(alice);
      vm.expectRevert("cannot set price higher than deposit");
      stakingPool.rageQuit(id, aliceDeposit + 1);
      //set ragequit
      vm.prank(alice);
      stakingPool.rageQuit(id, aliceDeposit);
      vm.prank(alice);
      frensPoolShare.approve(address(stakingPool), id);
      (uint price,/*time*/) = stakingPool.rageQuitInfo(id);
      assertEq(price, aliceDeposit, "price should = deposit");
      //try to unlock too soon
      vm.prank(alice);
      vm.expectRevert("allow one week before unlock");
      stakingPool.unlockTransfer(id);
      //fast forward
      vm.warp(block.timestamp + 1 weeks);
      //unlock transfer
      vm.prank(alice);
      stakingPool.unlockTransfer(id);
      assertFalse(stakingPool.locked(id));
      //test transfer
      vm.prank(alice);
      frensPoolShare.transferFrom(alice, bob, id);
      assertEq(frensPoolShare.ownerOf(id), bob, "bob should own it now");
    }

    function testRageQuitBuyOut(uint32 x) public {
      uint maxUint32 = 4294967296; //added 1 for fun (really to prevent over/underflow error)
      uint aliceDeposit = (uint(x) + 1) * 31999999999999999999 / (maxUint32);
      uint bobDeposit = 32000000000000000000 - aliceDeposit;
      hoax(alice);
      stakingPool.depositToPool{value: aliceDeposit}();
      hoax(bob);
      stakingPool.depositToPool{value: bobDeposit}();
      //test transfer lock
      uint id = frensPoolShare.tokenOfOwnerByIndex(alice, 0);
      uint idForBob = frensPoolShare.tokenOfOwnerByIndex(bob, 0);
      vm.expectRevert("not transferable");
      vm.prank(alice);
      frensPoolShare.transferFrom(alice, bob, id);
      //test setting price too high
      vm.prank(alice);
      vm.expectRevert("cannot set price higher than deposit");
      stakingPool.rageQuit(id, aliceDeposit + 1);
      //set ragequit
      vm.prank(alice);
      stakingPool.rageQuit(id, aliceDeposit);
      vm.prank(alice);
      frensPoolShare.approve(address(stakingPool), id);
      (uint price,/*time*/) = stakingPool.rageQuitInfo(id);
      assertEq(price, aliceDeposit, "price should = deposit");
      //try to unlock too soon
      vm.prank(alice);
      vm.expectRevert("allow one week before unlock");
      stakingPool.unlockTransfer(id);
      //cheapskate bob
      uint lowBall = price - 1;
      vm.prank(bob);
      vm.expectRevert("must send correct value");
      stakingPool.buyOut{value: lowBall}(id, idForBob);
      //buyout
      vm.prank(bob);
      stakingPool.buyOut{value: price}(id, idForBob);
      assertEq(frensPoolShare.ownerOf(id), bob, "bob should own it now");
      //should still be transfer locked
      vm.expectRevert("not transferable");
      vm.prank(bob);
      frensPoolShare.transferFrom(bob, alice, id);
    }

}
