const externals = require("../../../config.externals")["arbitrum-goerli"];

module.exports = [
  {
    contract: "AutomationEmitter",
  },
  {
    contract: "RequestLib",
  },
  {
    contract: "FeeManagerLib",
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
      // timeout
      5,
    ],
    deployerOptions: {
      libs: {
        RequestLib: (deploymentLock) => deploymentLock.RequestLib.addr,
        FeeManagerLib: (deploymentLock) => deploymentLock.FeeManagerLib.addr,
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
