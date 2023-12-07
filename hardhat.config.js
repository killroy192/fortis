const config = require("dotenv").config();

require("@nomicfoundation/hardhat-foundry");
require("@nomicfoundation/hardhat-toolbox");
require("./tasks");
require("hardhat-abi-exporter");

if (config.error) {
  console.error(config.error);
}

const deployerAccounts = [
  config?.parsed?.PRIVATE_KEY ||
    "0x0000000000000000000000000000000000000000000000000000000000000000",
];

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
    sepolia: {
      url: config?.parsed?.SEPOLIA_RPC_URL || "https:random.com",
      accounts: deployerAccounts,
    },
    anvil: {
      url: config?.parsed?.RPC_URL || "https:random.com",
      accounts: [
        "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80",
      ],
    },
    "arbitrum-sepolia": {
      url: config?.parsed?.ARBITRUM_SEPOLIA_RPC || "https:random.com",
      accounts: deployerAccounts,
    },
    "arbitrum-goerli": {
      url: config?.parsed?.ARBITRUM_GOERLI_RPC || "https:random.com",
      accounts: deployerAccounts,
    },
  },
  etherscan: {
    apiKey: {
      "arbitrum-sepolia": config?.parsed?.ABISCAN_API_KEY,
      "arbitrum-goerli": config?.parsed?.ABISCAN_API_KEY,
    },
    customChains: [
      {
        network: "arbitrum-sepolia",
        chainId: 421614,
        urls: {
          apiURL: "https://api-sepolia.arbiscan.io/api",
          browserURL: "https://sepolia-explorer.arbitrum.io",
        },
      },
      {
        network: "arbitrum-goerli",
        chainId: 421613,
        urls: {
          apiURL: "https://api-goerli.arbiscan.io/api",
          browserURL: "https://goerli.arbiscan.io/",
        },
      },
    ],
  },
};
