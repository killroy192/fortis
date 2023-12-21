const { getLock } = require("@dgma/hardhat-sol-bundler");

/**
 * Simple script to run onRegister in to safely set keeper id
 */
async function onRegister(oracleContractName, id, hre) {
  const lock = getLock(
    hre.userConfig.networks[hre.network.name].deployment.lockFile,
  )[hre.network.name];

  const oracle = await hre.ethers.getContractAt(
    oracleContractName,
    lock[oracleContractName].address,
  );

  await oracle.onRegister(BigInt(id));

  console.log("done\n");
}

task("onRegister", "Safely set keeper id to oracle")
  .addParam("id", "keeper id (numeric)")
  .addParam("oracle", "oracle name")
  .setAction(async (taskArgs, hre) =>
    onRegister(taskArgs.oracle, taskArgs.id, hre).catch((error) => {
      console.error(error);
      process.exitCode = 1;
    }),
  );
