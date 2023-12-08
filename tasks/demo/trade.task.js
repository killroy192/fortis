const { getDeploymentLockData } = require("../libs/common");

async function fundSwapApp(lock, usdc, hre) {
  const dec = await usdc.decimals();

  const balance = await usdc.balanceOf(lock.SwapApp.addr);

  if (balance < hre.ethers.parseUnits("1000000", dec)) {
    console.log("mint more...");
    await usdc.mint(lock.SwapApp.addr, hre.ethers.parseUnits("1000000", dec));
  }

  console.log("done\n");
}

/**
 * Script to run simple trade on swap app via automation (data streams)
 * also log states about execution from oracle side, aka is it possible to execute fallback
 */
async function trade(toSell, hre) {
  const { ethers, network } = hre;
  const coder = new ethers.AbiCoder();
  console.log("prepare..\n");
  const [signer] = await ethers.getSigners();
  const signerAddr = await signer.getAddress();
  const lock = (await getDeploymentLockData(hre))[network.name];

  const consumer = await ethers.getContractAt("SwapApp", lock.SwapApp.addr);

  const wethAddress = lock.FWETH.addr;
  const usdcAddress = lock.FUSDC.addr;

  const weth = await ethers.getContractAt("FWETH", wethAddress);
  const usdc = await ethers.getContractAt("FUSDC", usdcAddress);
  const oracle = await ethers.getContractAt(
    "FakedOracleProxy",
    lock.FakedOracleProxy.addr,
  );

  console.log("fund swappApp with USDC if needed\n");

  await fundSwapApp(lock, usdc, hre);

  console.log(`get and approve ${toSell} weth for trading\n`);
  const amountIn = ethers.parseEther(toSell);
  await weth.deposit({ value: amountIn });
  await weth.approve(lock.SwapApp.addr, amountIn);

  console.log("generate trade input\n");
  const nonce = Math.ceil(Math.random() * 100);
  const tradeArgs = {
    recipient: signerAddr,
    tokenIn: wethAddress,
    tokenOut: usdcAddress,
    amountIn: amountIn,
  };

  console.log(
    "tradeArgs",
    JSON.stringify({
      recipient: signerAddr,
      tokenIn: wethAddress,
      tokenOut: usdcAddress,
      amountIn: amountIn.toString(),
    }),
  );

  console.log("nonce", nonce);

  console.log("\nexecute trade");

  console.log("USD balance before trade: ", await usdc.balanceOf(signerAddr));

  await consumer.trade(tradeArgs, nonce, {
    value: hre.ethers.parseEther("0.001"),
  });

  console.log("wait for automation execution and balances updates..");
  await new Promise((res) => setTimeout(res, 10000));

  console.log("USD balance after trade: ", await usdc.balanceOf(signerAddr));

  console.log("\nrun fallback check logic..");

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

task("demo:trade", "Execute ETH\\USD trade on SwapApp")
  .addParam("amount", "link to swap for eth", "0.01")
  .setAction(async (args, hre) =>
    trade(args.amount, hre).catch((error) => {
      console.error(error);
      process.exitCode = 1;
    }),
  );
