const hre = require("hardhat");

module.exports = [
  {
    contract: "OracleRouter",
  },
  {
    contract: "MockConsumer",
    args: [(deploymentLock) => deploymentLock.OracleRouter.addr],
  },
];
