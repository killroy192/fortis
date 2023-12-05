const hre = require("hardhat");
const { getDeploymentLockData } = require("../../common");

/**
 * Simple script to fund contract with custom usdc.
 * Since usdc decimals is 6, ethers.parseEther("0.0001") will result to fund with 100k usdc
 */

async function main() {
  const lock = (await getDeploymentLockData())[hre.network.name];

  console.log("fund swapApp with minted usdc")

  const usdc = await hre.ethers.getContractAt("FUSDC", lock.FUSDC.addr);

  await usdc.mint(lock.SwapApp.addr, hre.ethers.parseEther("0.0001"));

  console.log("done\n");

  console.log("fund oracle treasure with eth");

  const oracle = await hre.ethers.getContractAt("FakedOracleProxy", lock.FakedOracleProxy.addr);

  const fee = await oracle.processingFee();

  console.log("funding fee", hre.ethers.formatEther(fee));

  await oracle.handlePayment({ value: fee });

  console.log("done\n");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
