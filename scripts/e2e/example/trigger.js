const hre = require("hardhat");
const { getDeploymentLockData } = require("../../common");

/**
 * Simple scrip to trigger SimpleConsumer and verify that it works
 */
async function main() {
  const nonce = () => Math.ceil(Math.random() * 100);
  const lock = await getDeploymentLockData();

  const consumer = await hre.ethers.getContractAt(
    "SimpleConsumer",
    lock[hre.network.name].SimpleConsumer.addr,
  );

  const oracle = await hre.ethers.getContractAt(
    "FakedOracleProxy",
    lock[hre.network.name].FakedOracleProxy.addr,
  );

  const fee = await oracle.processingFee();

  await consumer.trigger(
    {
      tokenIn: hre.ethers.ZeroAddress,
      tokenOut: hre.ethers.ZeroAddress,
      amountIn: hre.ethers.parseEther("10"),
    },
    nonce(),
    { value: fee }
  );

  await consumer.triggerFake(
    {
      tokenIn: hre.ethers.ZeroAddress,
      tokenOut: hre.ethers.ZeroAddress,
      amountIn: hre.ethers.parseEther("10"),
    },
    nonce(),
    { value: fee }
  );
}

main();
