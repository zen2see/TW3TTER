/* eslint-disable no-array-constructor */
/* eslint-disable no-unused-vars */
import { ethers } from "hardhat";
import "@nomiclabs/hardhat-ethers";
// eslint-disable-next-line node/no-extraneous-import
import { TransactionResponse } from "@ethersproject/abstract-provider";

const diamond = require("./diamond-util/index.ts");
const hre = require("hardhat");
// const { generatxorSvgs } = require('./diamond-util/index.ts')
// const { wearableSets } = require('./wearableSets.js')

function addCommas(nStr) {
  nStr += "";
  const x = nStr.split(".");
  let x1 = x[0];
  const x2 = x.length > 1 ? "." + x[1] : "";
  const rgx = /(\d+)(\d{3})/;
  while (rgx.test(x1)) {
    x1 = x1.replace(rgx, "$1" + "," + "$2");
  }
  return x1 + x2;
}

function strDisplay(str) {
  return addCommas(str.toString());
}

async function main(scriptName?: string) {
  console.log("SCRIPT NAME:", scriptName);
  const accounts = await ethers.getSigners();
  const account = await accounts[0].getAddress();
  // eslint-disable-next-line no-unused-vars
  const secondAccount = await accounts[1].getAddress();
  console.log("Account: " + account);
  console.log("--");
  let tx2: TransactionResponse;
  let totalGasUsed = ethers.BigNumber.from("0");
  let receipt;
  let vrfCoordinator;
  let linkAddress;
  let linkContract;
  let keyHash;
  let fee;
  let initialHauntSize;
  let tw3tTokenContract; // '0x176d1E71b0D795315f77E53Af6D97f03938EABc4' GENERATXORdiamond 0x6714193F40dC748A4AAa76A7608F7a210B5A2324
  let dao;
  let daoTreasury;
  let rarityFarming;
  let pixelCraft;
  let childChainManager;
  let tw3tStakingDiamond;
  let itemManagers;

  const gasLimit = 32300000;
  const portalPrice = ethers.utils.parseEther("100");
  const name = "Tw3tter";
  const symbol = "TW3T";

  if (hre.network.name === "hardhat") {
    childChainManager = account;
    // InitDiamond = account
    // const LinkTokenMock = await ethers.getContractFactory('LinkTokenMock')
    // linkContract = await LinkTokenMock.deploy()
    // await linkContract.deployed()
    // linkAddress = linkContract.address
    // keyHash = '0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4'
    // fee = ethers.utils.parseEther('0.0001')
  } else if (hre.network.name === "matic") {
    childChainManager = "0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa";
    vrfCoordinator = "0x3d2341ADb2D31f1c5530cDC622016af293177AE0";
    linkAddress = "0xb0897686c545045aFc77CF20eC7A532E3120E0F1";
    keyHash =
      "0xf86195cf7690c55907b2b611ebb7343a6f649bff128701cc542f0569e2c549da";
    fee = ethers.utils.parseEther("0.0001");
    // // Matic ghst token address
    // ghstTokenContract = await ethers.getContractAt('GHSTFacet', '0x385Eeac5cB85A38A9a07A70c73e0a3271CfB54A7')
    // ghstStakingDiamond = '0xA02d547512Bb90002807499F05495Fe9C4C3943f'
    // dao = 'todo' // await accounts[1].getAddress()
    // daoTreasury = 'todo'
    // rarityFarming = 'todo' // await accounts[2].getAddress()
    // pixelCraft = 'todo' // await accounts[3].getAddress()
  } else if (hre.network.name === "mumbai") {
    // childChainManager = '0xb5505a6d998549090530911180f38aC5130101c6'
    childChainManager = "0xb5505a6d998549090530911180f38aC5130101c6";
    vrfCoordinator = "0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9"; // wrong one
    linkAddress = "0x326C977E6efc84E512bB9C30f76E30c160eD06FB";
    keyHash =
      "0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4"; // wrong one
    fee = ethers.utils.parseEther("0.0001");

    initialHauntSize = "10000";

    // ghstTokenContract = await ethers.getContractAt('GHSTFacet', '0x658809Bb08595D15a59991d640Ed5f2c658eA284')
    tw3tTokenContract = await ethers.getContractAt(
      "TW3TFacet",
      "0x20d0A1ce31f8e8A77b291f25c5fbED007Adde932"
    );
  } else if (hre.network.name === "Arbitrum") {
    childChainManager = account;
    // arbiDai = '0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa';
  } else if (hre.network.name === "kovan") {
    childChainManager = account;
    vrfCoordinator = "0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9";
    linkAddress = "0xa36085F69e2889c224210F603D836748e7dC0088";
    keyHash =
      "0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4";
    fee = ethers.utils.parseEther("0.1");

    tw3tTokenContract = await ethers.getContractAt(
      "TW3TFacet",
      "0xAD2BA5a52DC26E8213Eceff3a04f21462F20b0E5"
    );
    // gxorStakingDiamond = '0xA4fF399Aa1BB21aBdd3FC689f46CCE0729d58DEd'

    // dao = account // 'todo' // await accounts[1].getAddress()
    // daoTreasury = account
    // rarityFarming = account // 'todo' // await accounts[2].getAddress()
    // pixelCraft = account // 'todo' // await accounts[3].getAddress()
    // itemManagers = [account] // 'todo'
    // mintAddress = account // 'todo'

    // mkDai = '0x4f96fe3b7a6cf9725f59d353f723c1bdb64ca6aa';
    // IUniswapRouter = '0xE592427A0AEce92De3Edee1F18E0157C05861564'
    // IQuoter = '0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6'
    // WETH9 = '0xd0A1E359811322d97991E03f863a0C30C2cF029C'
    tw3tStakingDiamond = "0xA02d547512Bb90002807499F05495Fe9C4C3943f";
    // const GhstTokenContract = await ethers.getContractFactory('GHSTFacet')
    // ghstTokenContract = await GhstTokenContract.deploy()
    // await ghstTokenContract.deployed()
    // await ghstTokenContract.mintTo('0x0b22380B7c423470979AC3eD7d3c07696773dEa1')
    // console.log('GHSTToken:' + ghstTokenContract.address)
    // throw 'done here'

    dao = account; // 'todo' // await accounts[1].getAddress()
    daoTreasury = account;
    rarityFarming = account; // 'todo' // await accounts[2].getAddress()
    pixelCraft = account; // 'todo' // await accounts[3].getAddress()
  } else {
    throw Error("No network settings for " + hre.network.name);
  }

  // deploy.ts script deploy()
  async function deployFacets(...facets) {
    const instances = Array();
    for (let facet of facets) {
      let constructorArgs = Array();
      if (Array.isArray(facet)) {
        [facet, constructorArgs] = facet;
      }
      console.log(
        "After deployFacets in deploy script the constructorArgs are: [" +
          constructorArgs +
          "]"
      );
      const factory = await ethers.getContractFactory(facet);
      const facetInstance = await factory.deploy(...constructorArgs);
      await facetInstance.deployed();
      tx2 = facetInstance.deployTransaction;
      const receipt = await tx2.wait();
      console.log(`${facet} deploy gas used: ` + strDisplay(receipt.gasUsed));
      totalGasUsed = totalGasUsed.add(receipt.gasUsed);
      instances.push(facetInstance);
    }
    return instances;
  }

  // let [
  //   bridgeFacet,
  //   aavegotchiFacet,
  //   aavegotchiGameFacet,
  //   svgFacet,
  //   itemsFacet,
  //   itemsTransferFacet,
  //   collateralFacet,
  //   daoFacet,
  //   vrfFacet,
  //   shopFacet,
  //   metaTransactionsFacet,
  //   erc1155MarketplaceFacet,
  //   erc721MarketplaceFacet,
  //   escrowFacet
  // ] = await deployFacets(

  const [tw3tterFacet] = await deployFacets(
    "contracts/tw3tter/facets/Tw3tterFacet.sol:Tw3tterFacet"
  );

  //  tw3tTokenContract = await diamond.deploy({
  //     diamondName: 'TW3TDiamond',
  //     initDiamond: 'contracts/TW3T/InitDiamond.sol:InitDiamond',
  //     facets: [
  //       'GXORFacet'
  //     ],
  //     owner: account
  //   })
  //   gxorTokenContract = await ethers.getContractAt('GXORFacet', gxorTokenContract.address)
  //   console.log('GXOR diamond address: ' + gxorTokenContract.address)

  // index.ts deploy()
  // eslint-disable-next-line no-unused-vars

  const tw3tterDiamond = await diamond.deploy({
    diamondName: "Tw3tterDiamond",
    initDiamond: "contracts/generatxor/InitDiamond.sol:InitDiamond",
    facets: [["Tw3tterFacet", tw3tterFacet]],
    owner: account,
    args: [[tw3tTokenContract.address, name, symbol]],
  });
  console.log("Tw3tter diamond address: " + tw3tterDiamond.address);
  const tx3 = tw3tterDiamond.deployTransaction;
  // eslint-disable-next-line prefer-const
  receipt = await tx3.wait();
  console.log(
    "Generatxor diamond deploy gas used: " + strDisplay(receipt.gasUsed)
  );
  totalGasUsed = totalGasUsed.add(receipt.gasUsed);

  // GXOR contract mint
  // gxorFacet = await ethers.getContractAt('contracts/GXOR/facets/GXORFacet.sol:GXORFacet', gxorFacet)
  // tx = await gxorFacet.mint()
  // receipt = await tx.wait()
  // if (!receipt.status) {
  //    throw Error(`Error:: ${tx.hash}`)
  // }
  // console.log("RECEIPT IS: " + receipt)
  // console.log('Mint() run')

  // Get name and symbol
  // generatxorFacet = await ethers.getContractAt('contracts/generatxor/facets/GeneratxorFacet.sol:GeneratxorFacet', generatxorDiamond.address)
  // tx2 = await generatxorFacet.name()
  // receipt = await tx2.wait()
  // if (!receipt.status) {
  //    throw Error(`Error:: ${tx2.hash}`)
  // }
  // console.log("RECEIPT IS: " + receipt)
  // console.log('NAME IS: ' + name)
  const diamondLoupeFacet = await ethers.getContractAt(
    "DiamondLoupeFacet",
    tw3tterDiamond.address
  );

  // // if (hre.network.name === 'matic') {
  //   // transfer ownership
  //   const newOwner = '0x94cb5C277FCC64C274Bd30847f0821077B231022'
  //   console.log('Transferring ownership of diamond: ' + generatxorDiamond.address)
  //   const diamond = await ethers.getContractAt('OwnershipFacet', generatxorDiamond.address)
  //   const tx = await diamond.transferOwnership(newOwner)
  //   console.log('Transaction hash: ' + tx.hash)
  //   receipt = await tx.wait()
  //   console.log('Transfer Transaction complete')
  //   console.log('Gas used:' + strDisplay(receipt.gasUsed))
  //   totalGasUsed = totalGasUsed.add(receipt.gasUsed)
  // // }

  console.log("Total gas used: " + strDisplay(totalGasUsed));
  return {
    account: account,
    tw3tterDiamond: tw3tterDiamond,
    diamondLoupeFacet: diamondLoupeFacet,
    tw3tTokenContract: tw3tTokenContract,
    tw3tterFacet: tw3tterFacet,
  };
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  main()
    // eslint-disable-next-line no-process-exit
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      // eslint-disable-next-line no-process-exit
      process.exit(1);
    });
}

export { main as deployProject };
