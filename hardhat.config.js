const config = require("dotenv").config();

require("@nomicfoundation/hardhat-foundry");
require("@nomicfoundation/hardhat-toolbox");
require("./tasks");
require("hardhat-abi-exporter");

if (config.error) {
  console.error(config.error);
}

const ZeroAddress = "0x0000000000000000000000000000000000000000";
const ZeroHash =
  "0x0000000000000000000000000000000000000000000000000000000000000000";

const deployerAccounts = [config?.parsed?.PRIVATE_KEY || ZeroHash];

const DEFAULT_RPC = "https:random.com";

const DEFAULT_EXTERNALS = {
  verifier: ZeroAddress,
  streamId: ZeroAddress,
  datafeed: ZeroAddress,
  linkNativeFeed: ZeroAddress,
  linkToken: ZeroAddress,
  registry: ZeroAddress,
};

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    compilers: [{ version: "0.8.20" }],
    metadata: {
      appendCBOR: false,
    },
  },
  paths: {
    sources: "./src",
    tests: "./integration",
  },
  networks: {
    hardhat: {
      deployment: {
        externals: DEFAULT_EXTERNALS,
      },
    },
    localhost: {
      deployment: {
        logFile: "./local.deployment-lock.json",
        externals: DEFAULT_EXTERNALS,
      },
    },
    "arbitrum-sepolia": {
      url: config?.parsed?.ARBITRUM_SEPOLIA_RPC || DEFAULT_RPC,
      accounts: deployerAccounts,
      deployment: {
        logFile: "./deployment-lock.json",
        verify: true,
        externals: {
          verifier: "0x2ff010DEbC1297f19579B4246cad07bd24F2488A",
          streamId:
            "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b",
          datafeed: "0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165",
          linkNativeFeed: "0x3ec8593F930EA45ea58c968260e6e9FF53FC934f",
          linkToken: "0xb1d4538b4571d411f07960ef2838ce337fe1e80e",
          registry: "0x8194399b3f11fca2e8ccefc4c9a658c61b8bf412",
        },
      },
    }
  },
  etherscan: {
    apiKey: {
      "arbitrum-sepolia": config?.parsed?.ABISCAN_API_KEY,
    },
    customChains: [
      {
        network: "arbitrum-sepolia",
        chainId: 421614,
        urls: {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://sepolia-explorer.arbitrum.io",
        },
      }
    ],
  },
};
