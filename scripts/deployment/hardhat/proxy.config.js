module.exports = [
  {
    contract: "MockOracleRouter",
  },
  {
    contract: "MockConsumer",
    args: [(deploymentLock) => deploymentLock.MockOracleRouter.addr],
  },
];
