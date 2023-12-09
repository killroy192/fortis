const deploy = require("./libs/deploy");

const config = (externals) => [
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
    contract: "Oracle",
    args: [
      // emitter
      (deploymentLock) => deploymentLock.AutomationEmitter.addr,
      // verifier
      externals.verifier,
      // eth/usd data stream id
      externals.streamId,
      // eth/usd data feed
      externals.datafeed,
      // link/eth data feed
      externals.linkNativeFeed,
      // link token
      externals.linkToken,
      // registry
      externals.registry,
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
  },
];

task("deploy", "Deploy fortis oracle contracts").setAction(
  async (_, hre) => {
    const { externals } = hre.userConfig.networks[hre.network.name].deployment;
    return deploy(config(externals), hre).catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
  },
);
