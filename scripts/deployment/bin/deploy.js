const fsp = require("node:fs/promises");
const fs = require("node:fs");
const path = require("node:path");
const hre = require("hardhat");

const loggedNetworks = ["arbitrum-sepolia"];

const isLoggedNetwork = () => loggedNetworks.includes(hre.network.name);

const getDeploymentLockData = async (filePath) => {
  const isExist = fs.existsSync(filePath);
  // skip localhost & one-time deployments
  return isExist && isLoggedNetwork()
    ? JSON.parse(await fsp.readFile(filePath))
    : {};
};

const getLibrariesDynamically = (deploymentLock, config = {}) =>
  Object.entries(config).reduce((acc, [libName, getter]) => {
    if (typeof getter === "function") {
      return {
        ...acc,
        [libName]: getter(deploymentLock),
      };
    }
    return {
      ...acc,
      [libName]: getter,
    };
  }, {});

const deployOnlyChanged =
  (deploymentConfig) =>
  async (deploymentLock = {}) => {
    const { contract, deployerOptions = {}, args = [] } = deploymentConfig;

    console.log("prepare deployment libraries");

    deployerOptions.libraries = getLibrariesDynamically(
      deploymentLock,
      deployerOptions?.libs,
    );

    console.log("prepare deployment arguments");

    const getDeploymentArgs = await args.map(async (arg) => {
      if (typeof arg === "function") {
        return arg(deploymentLock);
      }
      return arg;
    });

    console.log(getDeploymentArgs);

    const deploymentArgs = await Promise.all(getDeploymentArgs);

    console.log("deployerOptions", deployerOptions);
    console.log("deploymentArgs", deploymentArgs);

    console.log("Try deploy contract...", contract);
    const deployer = await hre.ethers.getContractFactory(
      contract,
      deployerOptions,
    );

    const contractLock = deploymentLock[contract];

    if (
      deployer.bytecode === contractLock?.code &&
      JSON.stringify(deploymentArgs) === JSON.stringify(contractLock?.args)
    ) {
      console.log("contract unchanged, skip deployment");
      return deploymentLock;
    }

    const deployment = await deployer.deploy(...deploymentArgs);

    await deployment.waitForDeployment();

    const contractAddress = await deployment.getAddress();

    console.log("Contract deployed, address:", contractAddress);

    if (isLoggedNetwork()) {
      console.log("verify newly deployed contract...");

      await hre.run("verify:verify", {
        address: contractAddress,
        constructorArguments: deploymentArgs,
      });
    }

    console.log("done!");

    return {
      ...deploymentLock,
      [contract]: {
        addr: contractAddress,
        code: deployer.bytecode,
        args: deploymentArgs,
      },
    };
  };

module.exports = async function main(config) {
  try {
    const networkName = hre.network.name;
    const filePath = path.resolve("deployment-lock.json");

    const currentDeploymentLock = await getDeploymentLockData(filePath);

    const deploymentResult = await config.reduce(
      (acc, c) => acc.then(deployOnlyChanged(c)),
      Promise.resolve(currentDeploymentLock[networkName]),
    );

    console.log(`Deployment to ${networkName} has finished`);

    const result = {
      ...currentDeploymentLock,
      [networkName]: deploymentResult,
    };

    if (loggedNetworks.includes(networkName)) {
      console.log("update lock file");
      await fsp.writeFile(filePath, JSON.stringify(result));
    }
    console.log("Done");
    return deploymentResult;
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};
