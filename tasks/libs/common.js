const fsp = require("node:fs/promises");
const fs = require("node:fs");
const path = require("node:path");

const getFilePath = (hre) => {
  return path.resolve(
    hre.userConfig.networks[hre.network.name]?.deploy?.logFile || "",
  );
};

const isLoggedNetwork = (hre) =>
  hre.userConfig.networks[hre.network.name]?.deploy?.logFile;
const isVerifyNetwork = (hre) =>
  hre.userConfig.networks[hre.network.name]?.deploy?.verify;

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
