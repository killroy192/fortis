const deploy = require("../libs/deploy");
const { externals } = require("../config.global");

const config = (externalDeps) => [
  {
    contract: "AutomationEmitter",
  },
  {
    contract: "RequestLib",
  },
  {
    contract: "FeeLib",
  },
  {
    contract: "VerifierLib",
  },
  {
    contract: "FakedOracle",
    args: [
      // emitter
      (deploymentLock) => deploymentLock.AutomationEmitter.addr,
      // verifier
      externalDeps.verifier,
      // eth/usd data stream id
      externalDeps.streamId,
      // eth/usd data feed
      externalDeps.datafeed,
      // link/eth data feed
      externalDeps.linkNativeFeed,
      // link token
      externalDeps.linkToken,
      // registry
      externalDeps.registry,
      // timeout
      3,
    ],
    deployerOptions: {
      libs: {
        RequestLib: (deploymentLock) => deploymentLock.RequestLib.addr,
        FeeLib: (deploymentLock) => deploymentLock.FeeLib.addr,
        VerifierLib: (deploymentLock) => deploymentLock.VerifierLib.addr,
      },
    },
    skipVerify: true,
  },
  {
    contract: "FakedOracleProxy",
  },
  {
    contract: "SwapApp",
    args: [(deploymentLock) => deploymentLock.FakedOracleProxy.addr],
  },
  {
    contract: "FWETH",
  },
  {
    contract: "FUSDC",
  },
];

/**
 * @dev Script to update oracle
 * @note For demo we should deploy a simple proxy on top of main Oracle.
 * This helps speed up development and experimentation.
 * There might be beneficial to migrate to openzeppelin proxy hardhat plugin
 * @param {Object} lock
 */
const upgradeMockOracle = (hre) => async (lock) => {
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

task("deploy:demo", "Deploy and upgrade demo contracts").setAction(
  async (args, hre) => {
    const externalsNetwork =
      hre.network.name === "hardhat" ? "localhost" : hre.network.name;
    return deploy(config(externals[externalsNetwork]), hre)
      .then(upgradeMockOracle(hre))
      .catch((error) => {
        console.error(error);
        process.exitCode = 1;
      });
  },
);
