const hre = require("hardhat");
const {
  getDeploymentLockData,
} = require("../common");

const findContractByName = (lock, contractName) => {
  const contractConfig = Object.entries(lock[hre.network.name]).find(
    ([key]) => key === contractName,
  );
  if (contractConfig) {
    return contractConfig[1];
  }
};

async function main() {
  const lock = await getDeploymentLockData();

  const consumer = await hre.ethers.getContractAt(
    "MockConsumer",
    findContractByName(lock, "MockConsumer").addr,
  );

  await consumer.trigger({
    tokenIn: hre.ethers.ZeroAddress,
    tokenOut: hre.ethers.ZeroAddress,
    amountIn: hre.ethers.parseEther("10"),
  });
}

main();
