const { getDeploymentLockData } = require("./libs/common");

/**
 * Simple script to run onRegister in to safely set keeper id
 */
async function onRegister(oracleContractName, id, hre) {
  const lock = (await getDeploymentLockData(hre))[hre.network.name];

  const oracle = await hre.ethers.getContractAt(
    oracleContractName,
    lock[oracleContractName].addr,
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
