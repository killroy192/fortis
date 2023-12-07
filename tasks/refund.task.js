const { getDeploymentLockData } = require("./libs/common");
const { externals } = require("./config.global");

/**
 * Simple script to run onRegister in to safely set keeper id
 */

async function refund(oracleContractName, linkToSpend, hre) {
  const lock = (await getDeploymentLockData(hre))[hre.network.name];
  const [signer] = await ethers.getSigners();

  console.log("swap link to eth and refund oracle");

  const oracle = await hre.ethers.getContractAt(
    oracleContractName,
    lock[oracleContractName].addr,
  );

  const linkToken = await hre.ethers.getContractAt(
    "LinkTokenInterface",
    externals[hre.network.name].linkToken,
  );

  const amount = hre.ethers.parseUnits(linkToSpend, (await linkToken.decimals()));

  const resp = await oracle.swapPreview(amount);
  console.log("swapPreview", resp);
  if (resp[0]) {
    await linkToken.approve(lock[oracleContractName].addr, amount);
    await oracle.swap(await signer.getAddress(), amount);
    console.log("done");
  } else {
    console.log("cant swap, not enough eth in treasure");
  }
}

task("refund", "Refund oracle via eth\\link swap")
  .addParam("oracle", "oracle name")
  .addParam("amount", "link to swap for eth")
  .setAction(async (taskArgs, hre) =>
    refund(taskArgs.oracle, taskArgs.amount, hre).catch((error) => {
      console.error(error);
      process.exitCode = 1;
    }),
  );
