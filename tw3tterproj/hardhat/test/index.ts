import { expect } from "chai";
import { ethers } from "hardhat";

describe("Tw33tter", function () {
  it("Should return the new tw33ting once it's changed", async function () {
    const Tw33tterTest = await ethers.getContractFactory("Tw33tterTest");
    const tw33tter = await Tw33tterTest.deploy("Hello, world!");
    await tw33tter.deployed();

    expect(await tw33tter.tw33tter()).to.equal("Hello, world!");

    const setTw33ttingTx = await tw33tter.setTw33tter("Hola, mundo!");

    // wait until the transaction is mined
    await setTw33ttingTx.wait();

    expect(await tw33tter.tw33tter()).to.equal("Hola, mundo!");
  });
});
