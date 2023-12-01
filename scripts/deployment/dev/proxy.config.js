const hre = require("hardhat");

module.exports = [
  {
    contract: "InitBeacon",
  },
  {
    contract: "UpgradeableBeacon",
    args: [
      (deploymentLock) => deploymentLock.InitBeacon.addr,
      async () => (await hre.ethers.getSigners())[0].address,
    ],
  },
  {
    contract: "BeaconProxy",
    args: [
      (deploymentLock) => deploymentLock.UpgradeableBeacon.addr, "0x"
    ],
  },
  {
    contract: "MockConsumer",
    args: [(deploymentLock) => deploymentLock.BeaconProxy.addr],
  },
];
