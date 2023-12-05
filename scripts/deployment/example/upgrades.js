const hre = require("hardhat");

async function upgradeMockOracle(lock) {
  console.log("\nrun script for upgrade FakedOracle\n");
  const FakedOracleProxyContract = await hre.ethers.getContractAt(
    "FakedOracleProxy",
    lock.FakedOracleProxy.addr,
  );

  const currentImplementation = await FakedOracleProxyContract.implementation();
  const newImplementation = lock.FakedOracle.addr;
  if (currentImplementation !== newImplementation) {
    console.log("start automatic migration");
    await FakedOracleProxyContract.upgradeTo(newImplementation);
    console.log("done");
    // need to fund contract under router
    const currentImplementation =
      await FakedOracleProxyContract.implementation();
    console.log(
      `trigger test event for ${lock.FakedOracleProxy.addr} -> ${currentImplementation}`,
    );
    const consumer = await hre.ethers.getContractAt(
      "SimpleConsumer",
      lock.SimpleConsumer.addr,
    );

    await consumer.trigger(
      {
        tokenIn: hre.ethers.ZeroAddress,
        tokenOut: hre.ethers.ZeroAddress,
        amountIn: hre.ethers.parseEther("10"),
      },
      Math.ceil(Math.random() * 100),
      { value: hre.ethers.parseEther("0.005") },
    );
  }

  console.log("\ndone\n");
}

async function upgrades(lock, linkTokenAddr) {
  await upgradeMockOracle(lock, linkTokenAddr);
}

module.exports = upgrades;
