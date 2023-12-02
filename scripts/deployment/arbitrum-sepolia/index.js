const hre = require("hardhat");
const deploy = require("../bin/deploy");
const proxy = require("./proxy.config");
const oracle = require("./oracle.config");

async function main() {
  const proxyLock = await deploy(proxy);
  const oracleLock = await deploy(oracle);

  const routerContract = await hre.ethers.getContractAt(
    "MockOracleRouter",
    proxyLock.MockOracleRouter.addr,
  );

  const currentImplementation = await routerContract.implementation();
  const newImplementation = oracleLock[oracle[oracle.length - 1].contract].addr;
  if (currentImplementation !== newImplementation) {
    console.log("start automatic migration");
    await routerContract.upgradeTo(newImplementation);
    const linkToken = await hre.ethers.getContractAt(
      "IERC20",
      "0xb1d4538b4571d411f07960ef2838ce337fe1e80e",
    );
    console.log("done");
    // need to fund contract under router
    console.log("fund new oracle");
    await linkToken.transfer(newImplementation, hre.ethers.parseEther("0.1"));
    console.log("trigger test event");
    const consumer = await hre.ethers.getContractAt(
      "MockConsumer",
      proxyLock[proxy[proxy.length - 1].contract].addr,
    );

    await consumer.trigger(
      {
        tokenIn: hre.ethers.ZeroAddress,
        tokenOut: hre.ethers.ZeroAddress,
        amountIn: hre.ethers.parseEther("10"),
      },
      Math.ceil(Math.random() * 100),
    );
  }

  console.log("done");
}

main();
