/**
 * @dev Script to update oracle
 * @note For demo we should deploy a simple proxy on top of main Oracle.
 * This helps speed up development and experimentation.
 * There might be beneficial to migrate to openzeppelin proxy hardhat plugin
 * @param {Object} lock
 */
const upgradeMockOracle = async (hre, lock) => {
  console.log("\nrun script for upgrade FakedOracle\n");
  const FakedOracleProxyContract = await hre.ethers.getContractAt(
    "FakedOracleProxy",
    lock.FakedOracleProxy.addr,
  );

  const currentImplementation = await FakedOracleProxyContract.implementation();
  const newImplementation = lock.FakedOracle.addr;
  if (currentImplementation !== newImplementation) {
    console.log("start automatic migration");
    await FakedOracleProxyContract.upgradeTo(newImplementation);
    console.log("done");
  }

  console.log("\ndone\n");
};

task("demo:migrate", "upgrades demo-related contracts").setAction(
  async (_, hre) => {
    return upgradeMockOracle().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
  },
);
