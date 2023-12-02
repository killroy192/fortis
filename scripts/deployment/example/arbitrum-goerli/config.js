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
      "0xcB1241Fdf26501fA7A2d47d841dcF72C3CAa9dCe",
      // eth/usd data stream id
      "0x00029584363bcf642315133c335b3646513c20f049602fc7d933be0d3f6360d3",
      // eth/usd data feed
      "0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165",
      // timeout
      5,
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
];
