module.exports = [
  {
    contract: "SimpleOracleProxy",
    args: [ethers.ZeroAddress]
  },
  {
    contract: "MockConsumer",
    args: [(deploymentLock) => deploymentLock.SimpleOracleProxy.addr],
  },
]