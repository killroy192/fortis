const hre = require("hardhat");
const { getDeploymentLockData } = require("../../common");
const externals = require("../../config.externals");

/**
 * Simple script to run onRegister in to safely set keeper id
 */

const coder = new ethers.AbiCoder();

async function main() {
  const lock = (await getDeploymentLockData())[hre.network.name];
  const [signer] = await ethers.getSigners();

  console.log("arb link to eth");

  const amount = hre.ethers.parseEther("1");

  /**
   *  need to call oracle directly since we need to operate with method that uses msg.seder
   */
  const oracle = await hre.ethers.getContractAt(
    "FakedOracle",
    lock.FakedOracle.addr,
  );

  const linkToken = await hre.ethers.getContractAt(
    "LinkTokenInterface",
    externals[hre.network.name].linkToken,
  );

  const resp = await oracle.swapPreview(amount);
  console.log("swapPreview", resp);
  if (resp[0]) {
    await linkToken.approve(lock.FakedOracle.addr, amount);
    await oracle.swap(await signer.getAddress(), amount);
    console.log("done");
  } else {
    console.log("cant swap, not enough eth in treasure");
  }
  // const result = await linkToken.transferAndCall(
  //   externals[hre.network.name].registry,
  //   amount,
  //   coder.encode(["uint256"], [amount]),
  // );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
