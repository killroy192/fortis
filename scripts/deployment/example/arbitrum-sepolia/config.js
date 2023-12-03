const externals = require("../../../config.externals")["arbitrum-sepolia"];

module.exports = [
  {
    contract: "RequestLib",
  },
  {
    contract: "AutomationEmitter",
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
      60,
    ],
    deployerOptions: {
      libs: {
        RequestLib: (deploymentLock) => deploymentLock.RequestLib.addr,
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
