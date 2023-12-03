const hre = require("hardhat");
const { getDeploymentLockData } = require("../../common");

/**
 * Simple scrip to trigger SimpleConsumer and verify that it works
 */
async function main() {
  const lock = await getDeploymentLockData();

  const consumer = await hre.ethers.getContractAt(
    "SimpleConsumer",
    lock[hre.network.name].SimpleConsumer.addr,
  );

  await consumer.trigger(
    {
      tokenIn: hre.ethers.ZeroAddress,
      tokenOut: hre.ethers.ZeroAddress,
      amountIn: hre.ethers.parseEther("10"),
    },
    Math.ceil(Math.random() * 100),
  );

  await consumer.triggerFake(
    {
      tokenIn: hre.ethers.ZeroAddress,
      tokenOut: hre.ethers.ZeroAddress,
      amountIn: hre.ethers.parseEther("10"),
    },
    Math.ceil(Math.random() * 100),
  );
}

main();
