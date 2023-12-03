const fsp = require("node:fs/promises");
const fs = require("node:fs");
const path = require("node:path");
const hre = require("hardhat");

const loggedNetworks = ["arbitrum-sepolia", "arbitrum-goerli", "localhost"];
const verifyNetwork = ["arbitrum-sepolia", "arbitrum-goerli"];
const filePath = path.resolve("deployment-lock.json");

const isLoggedNetwork = () => loggedNetworks.includes(hre.network.name);
const isVerifyNetwork = () => verifyNetwork.includes(hre.network.name);

const getDeploymentLockData = async () => {
  const isExist = fs.existsSync(filePath);
  // skip localhost & one-time deployments
  return isExist && isLoggedNetwork()
    ? JSON.parse(await fsp.readFile(filePath))
    : {};
};

const updateDeploymentLockData = (result) => {
  if (isLoggedNetwork()) {
    console.log("update lock file");
    return fsp.writeFile(filePath, JSON.stringify(result));
  }
}

module.exports = {
  isLoggedNetwork,
  isVerifyNetwork,
  getDeploymentLockData,
  updateDeploymentLockData,
}