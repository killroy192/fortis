const { getLock } = require("@dgma/hardhat-sol-bundler");

/**
 * @dev Script to update oracle
 * @note For demo we should deploy a simple proxy on top of main Oracle.
 * This helps speed up development and experimentation.
 * Might be beneficial to migrate to openzeppelin proxy hardhat plugin
 * @param {Object} lock
 */
const upgradeMockOracle = async (hre, lock) => {
  if (!lock) {
    console.log("no lock file has been found, cancel");
    return;
  }
  console.log("\nrun script for upgrade FakedOracle\n");
  const FakedOracleProxyContract = await hre.ethers.getContractAt(
    "FakedOracleProxy",
    lock.FakedOracleProxy.address,
  );

  const currentImplementation = await FakedOracleProxyContract.implementation();
  const newImplementation = lock.FakedOracle.address;
  if (currentImplementation !== newImplementation) {
    console.log("start automatic migration");
    await FakedOracleProxyContract.upgradeTo(newImplementation);
    console.log("done");
  }

  console.log("\ndone\n");
};

task("demo:migrate", "upgrades demo-related contracts").setAction(async (_, hre) => {
  const lock = getLock(hre.userConfig.networks[hre.network.name].deployment.lockFile)[
    hre.network.name
  ];
  return upgradeMockOracle(hre, lock).catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
});
