const {
  isVerifyNetwork,
  getDeploymentLockData,
  updateDeploymentLockData,
} = require("./common");

/**
 * Deployment script.
 * Consumes deployment config and deploy only changed contracts.
 */

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
  (deploymentConfig, hre) =>
  async (deploymentLock = {}) => {
    const {
      contract,
      deployerOptions = {},
      args = [],
      skipVerify,
    } = deploymentConfig;

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

    if (isVerifyNetwork(hre) && !skipVerify) {
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

module.exports = async function main(config, hre) {
  try {
    const networkName = hre.network.name;

    const currentDeploymentLock = await getDeploymentLockData(hre);

    const deploymentResult = await config.reduce(
      (acc, c) => acc.then(deployOnlyChanged(c, hre)),
      Promise.resolve(currentDeploymentLock[networkName]),
    );

    console.log(`Deployment to ${networkName} has finished`);

    const result = {
      ...currentDeploymentLock,
      [networkName]: deploymentResult,
    };

    await updateDeploymentLockData(result, hre);

    console.log("Done");
    return deploymentResult;
  } catch (error) {
    console.error(error);
    process.exit(1);
  }
};
