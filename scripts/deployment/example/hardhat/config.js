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
      "0x2ff010DEbC1297f19579B4246cad07bd24F2488A",
      // eth/usd data stream id
      "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b",
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
