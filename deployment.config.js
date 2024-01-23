const { dynamicAddress } = require("@dgma/hardhat-sol-bundler");
const { VerifyPlugin } = require("@dgma/hardhat-sol-bundler/plugins/Verify");

const common = {
  AutomationEmitter: {},
  RequestLib: {},
  FeeLib: {},
  VerifierLib: {},
};


const config = {}

module.exports = {
  hardhat: {
    config: config,
  },
  localhost: { lockFile: "./local.deployment-lock.json", config: config },
  "NETWORK_NAME": {
    lockFile: "./deployment-lock.json",
    verify: true,
    plugins: [VerifyPlugin],
    config: config,
  },
};
