const hre = require("hardhat");
const deploy = require("../bin/deploy");
const proxy = require("./proxy.config");
const oracle = require("./oracle.config");

async function main() {
  const proxyLock = await deploy(proxy);
  const oracleLock = await deploy(oracle);

  const proxyContract = await hre.ethers.getContractAt(
    "SimpleOracleProxy",
    proxyLock.SimpleOracleProxy.addr,
  );

  const currentImplementation = await proxyContract.currentImplementation();
  const newImplementation = oracleLock[oracle[1].contract].addr;
  if (currentImplementation !== newImplementation) {
    console.log("start automatic migration");
    await proxyContract.upgrade(newImplementation);
    const linkToken = await hre.ethers.getContractAt(
      "IERC20",
      "0xb1d4538b4571d411f07960ef2838ce337fe1e80e",
    );
    console.log("done");
    // need to fund proxy
    // console.log("fund new oracle");
    // await linkToken.transfer(
    //   newImplementation,
    //   hre.ethers.parseEther("0.1")
    // );
    console.log("trigger test event");
    const consumer = await hre.ethers.getContractAt(
      "MockConsumer",
      proxyLock[proxy[1].contract].addr,
    );

    await consumer.triggerHardcoded();
  }

  console.log("done");
}

main();
