const { getLock } = require("@dgma/hardhat-sol-bundler");

/**
 * Simple script to run onRegister in to safely set keeper id
 */

async function refund(oracleContractName, linkToSpend, hre) {
  const lock = getLock(
    hre.userConfig.networks[hre.network.name].deployment.lockFile,
  )[hre.network.name];
  const [signer] = await ethers.getSigners();

  console.log("swap link to eth and refund oracle");

  const oracle = await hre.ethers.getContractAt(
    oracleContractName,
    lock[oracleContractName].address,
  );

  const linkToken = await hre.ethers.getContractAt(
    "LinkTokenInterface",
    hre.userConfig.networks[hre.network.name].deployment.externals.linkToken,
  );

  const amount = hre.ethers.parseUnits(linkToSpend, await linkToken.decimals());

  const resp = await oracle.swapPreview(amount);
  console.log("swapPreview", resp);
  if (resp[0]) {
    await linkToken.approve(lock[oracleContractName].address, amount);
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
