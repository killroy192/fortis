const externals = require("../../../config.externals").hardhat;

module.exports = [
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
      5,
    ],
    deployerOptions: {
      libs: {
        RequestLib: (deploymentLock) => deploymentLock.RequestLib.addr,
        FeeLib: (deploymentLock) => deploymentLock.FeeLib.addr,
        VerifierLib: (deploymentLock) => deploymentLock.VerifierLib.addr,
      },
    },
  },
  {
    contract: "FakedOracleProxy",
  },
  {
    contract: "SimpleConsumer",
    args: [(deploymentLock) => deploymentLock.FakedOracleProxy.addr],
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
