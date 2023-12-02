const hre = require("hardhat");
const { getDeploymentLockData } = require("../common");

async function main() {
  const lock = await getDeploymentLockData();

  const consumer = await hre.ethers.getContractAt(
    "MockConsumer",
    lock[hre.network.name].MockConsumer.addr
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

main();
