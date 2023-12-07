const fsp = require("node:fs/promises");
const fs = require("node:fs");
const path = require("node:path");
const {
  loggedNetworks,
  verifyNetwork,
  localDeploymentFileName,
  deploymentFileName,
} = require("../config.global");

const getFilePath = (hre) => {
  const fileName =
    hre.network.name === "localhost"
      ? localDeploymentFileName
      : deploymentFileName;
  return path.resolve(fileName);
};

const isLoggedNetwork = (hre) => loggedNetworks.includes(hre.network.name);
const isVerifyNetwork = (hre) => verifyNetwork.includes(hre.network.name);

const getDeploymentLockData = async (hre) => {
  const filePath = getFilePath(hre);
  const isExist = fs.existsSync(filePath);
  // skip localhost & one-time deployments
  return isExist && isLoggedNetwork(hre)
    ? JSON.parse(await fsp.readFile(filePath))
    : {};
};

const updateDeploymentLockData = (result, hre) => {
  if (isLoggedNetwork(hre)) {
    const filePath = getFilePath(hre);
    console.log("update lock file");
    return fsp.writeFile(filePath, JSON.stringify(result));
  }
};

module.exports = {
  isLoggedNetwork,
  isVerifyNetwork,
  getDeploymentLockData,
  updateDeploymentLockData,
};
