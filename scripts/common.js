const loggedNetworks = ["arbitrum-sepolia"];

const isLoggedNetwork = () => loggedNetworks.includes(hre.network.name);

const getDeploymentLockData = async () => {
  const filePath = path.resolve("deployment-lock.json");
  const isExist = fs.existsSync(filePath);
  // skip localhost & one-time deployments
  return isExist && isLoggedNetwork()
    ? JSON.parse(await fsp.readFile(filePath))
    : {};
};

module.exports = {
  isLoggedNetwork,
  getDeploymentLockData,
}