const hre = require("hardhat");
const { getDeploymentLockData } = require("../../common");

/**
 * Simple script to run onRegister in to safely set keeper id
 */

async function main() {
  const lock = (await getDeploymentLockData())[hre.network.name];

  console.log("set registry id");

  /**
   *  need to call oracle directly since we need to operate with method that uses msg.seder
   */
  const oracle = await hre.ethers.getContractAt(
    "FakedOracle",
    lock.FakedOracle.addr,
  );

  await oracle.onRegister(
    BigInt(
      "89952514243017934716033768627602967835059820889355838654103693703888661118986",
    ),
  );

  console.log("done\n");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
