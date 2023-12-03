const { ethers } = require("hardhat");
const { getDeploymentLockData } = require("../../common");

const coder = new ethers.AbiCoder();

/**
 * Script to run simple trade on swap app via automation (data streams)
 * also log states about execution from oracle side, aka is it possible to execute fallback
 */
async function main() {
  console.log("prepare..");
  const [signer] = await ethers.getSigners();
  const signerAddr = await signer.getAddress();
  const lock = (await getDeploymentLockData())[hre.network.name];

  const consumer = await hre.ethers.getContractAt("SwapApp", lock.SwapApp.addr);

  const wethAddress = lock.FWETH.addr;
  const usdcAddress = lock.FUSDC.addr;

  const weth = await ethers.getContractAt("FWETH", wethAddress);
  console.log("done\n");

  // Trade WETH <> USDC
  const amountIn = ethers.parseEther("0.001");
  console.log("get 0.001 weth for trading");
  await weth.deposit({ value: amountIn });
  console.log("done\n");
  console.log("approve 0.001 weth for trade");
  await weth.approve(lock.SwapApp.addr, amountIn);
  console.log("done\n");
  console.log("generate trade input");
  const nonce = Math.ceil(Math.random() * 100);
  const tradeArgs = {
    recipient: signerAddr,
    tokenIn: wethAddress,
    tokenOut: usdcAddress,
    amountIn: amountIn,
  };
  console.log("trade nonce", nonce);
  console.log(
    "tradeArgs",
    JSON.stringify({
      recipient: signerAddr,
      tokenIn: wethAddress,
      tokenOut: usdcAddress,
      amountIn: "BigInt 0.001",
    }),
  );
  console.log("done\n");
  console.log("execute trade");
  await consumer.trade(tradeArgs, nonce);
  console.log("Successfully traded fWETH tokens for fUSDC");

  console.log("run fallback check logic..");
  const oracle = await hre.ethers.getContractAt(
    "FakedOracleProxy",
    lock.FakedOracleProxy.addr,
  );

  const bytesCallbackArgs = coder.encode(
    [
      "tuple(address recipient, address tokenIn, address tokenOut, uint256 amountIn)",
    ],
    [tradeArgs],
  );

  const result = await oracle.previewFallbackCall(
    consumer,
    bytesCallbackArgs,
    nonce,
    tradeArgs.recipient,
  );

  console.log("previewFallbackCall call result", result);

  console.log("done\n");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
