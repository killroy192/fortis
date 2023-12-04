const hre = require("hardhat");

async function upgradeMockOracle(lock, linkTokenAddr) {
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
    const linkToken = await hre.ethers.getContractAt("IERC20", linkTokenAddr);
    console.log("done");
    // need to fund contract under router
    console.log("fund new oracle");
    await linkToken.transfer(newImplementation, hre.ethers.parseEther("0.1"));
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
      { value: hre.ethers.parseEther("0.01") },
    );
  }

  console.log("\ndone\n");
}

async function upgrades(lock, linkTokenAddr) {
  await upgradeMockOracle(lock, linkTokenAddr);
}

module.exports = upgrades;
