const { ethers } = require("hardhat");
const { getDeploymentLockData } = require("../../common");

/**
 * Simple script to fund contract with custom usdc.
 * Since usdc decimals is 6, ethers.parseEther("0.0001") will result to fund with 100k usdc
 */

async function main() {
  const lock = (await getDeploymentLockData())[hre.network.name];

  const usdc = await hre.ethers.getContractAt("FUSDC", lock.FUSDC.addr);

  usdc.mint(lock.SwapApp.addr, ethers.parseEther("0.0001"));

  console.log("Successfully fund swapApp with USDC");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
