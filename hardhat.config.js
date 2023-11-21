const config = require('dotenv').config();

// require('@nomicfoundation/hardhat-toolbox');
require("@nomicfoundation/hardhat-foundry");

if (config.error) {
  console.error(config.error);
}

const deployerAccounts = [
  config?.parsed?.PRIVATE_KEY ||
    "0x0000000000000000000000000000000000000000000000000000000000000000",
]

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.20',
    metadata: {
      appendCBOR: false,
    },
  },
  paths: {
    tests: "./integration",
  },
  networks: {
    sepolia: {
      url: config?.parsed?.SEPOLIA_RPC_URL || "https:random.com",
      accounts: deployerAccounts,
    },
    anvil: {
      url: config?.parsed?.RPC_URL || "https:random.com",
      accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"],
    }
  },
};
