const { ethers } = require("hardhat");
const { getDeploymentLockData } = require("../../common");

// arbitrum-goerli only

async function main() {
  const [signer] = await ethers.getSigners();
  const lock = await getDeploymentLockData();

  const consumer = await hre.ethers.getContractAt(
    "SwapApp",
    lock[hre.network.name].SwapApp.addr,
  );

  const wethAddress = "0xe39ab88f8a4777030a534146a9ca3b52bd5d43a3";
  const usdc = "0x8fb1e3fc51f3b789ded7557e680551d93ea9d892";

  const feedsId =
    "0x00029584363bcf642315133c335b3646513c20f049602fc7d933be0d3f6360d3";

  const amountIn = ethers.parseEther("0.001");

  // Trade WETH <> USDC
  const weth = await ethers.getContractAt("IERC20", wethAddress);

  await weth.approve(await consumer.getAddress(), amountIn);
  await consumer.trade(
    wethAddress,
    usdc,
    amountIn,
    feedsId,
    Math.ceil(Math.random() * 100),
  );
  console.log("Successfully traded WETH tokens for USDC");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
