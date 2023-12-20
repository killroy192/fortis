const { ZeroAddress } = require("ethers");
const { dynamicAddress } = require("@dgma/hardhat-sol-bundler");
const {
  VerifyPlugin,
} = require("@dgma/hardhat-sol-bundler/dist/plugins/Verify");

const DEFAULT_EXTERNALS = {
  Verifier: ZeroAddress,
  StreamId: ZeroAddress,
  Datafeed: ZeroAddress,
  LinkNativeFeed: ZeroAddress,
  LinkToken: ZeroAddress,
  Registry: ZeroAddress,
};

const common = {
  AutomationEmitter: {},
  RequestLib: {},
  FeeLib: {},
  VerifierLib: {},
  FWETH: {},
  FUSDC: {},
  FakedOracleProxy: {},
  SwapApp: {
    args: dynamicAddress("FakedOracleProxy"),
  },
};

const hardhatConfig = {
  ...common,
  FakedOracle: {
    args: [
      // emitter
      dynamicAddress("AutomationEmitter"),
      // verifier
      DEFAULT_EXTERNALS.Verifier,
      // eth/usd data stream id
      DEFAULT_EXTERNALS.StreamId,
      // eth/usd data feed
      DEFAULT_EXTERNALS.Datafeed,
      // link/eth data feed
      DEFAULT_EXTERNALS.LinkNativeFeed,
      // link token
      DEFAULT_EXTERNALS.LinkToken,
      // registry
      DEFAULT_EXTERNALS.Registry,
      // timeout
      3,
    ],
    options: {
      libs: {
        RequestLib: dynamicAddress("RequestLib"),
        FeeLib: dynamicAddress("FeeLib"),
        VerifierLib: dynamicAddress("VerifierLib"),
      },
    },
  },
};

module.exports = {
  hardhat: {
    config: hardhatConfig,
  },
  localhost: {
    lockFile: "./local.deployment-lock.json",
    config: hardhatConfig,
  },
  "arbitrum-sepolia": {
    lockFile: "./deployment-lock.json",
    verify: true,
    plugins: [VerifyPlugin],
    config: {
      ...common,
      FakedOracle: {
        args: [
          // emitter
          dynamicAddress("AutomationEmitter"),
          // verifier
          "0x2ff010DEbC1297f19579B4246cad07bd24F2488A",
          // eth/usd data stream id
          "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b",
          // eth/usd data feed
          "0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165",
          // link/eth data feed
          "0x3ec8593F930EA45ea58c968260e6e9FF53FC934f",
          // link token
          "0xb1d4538b4571d411f07960ef2838ce337fe1e80e",
          // registry
          "0x8194399b3f11fca2e8ccefc4c9a658c61b8bf412",
          // timeout
          3,
        ],
        options: {
          libs: {
            RequestLib: dynamicAddress("RequestLib"),
            FeeLib: dynamicAddress("FeeLib"),
            VerifierLib: dynamicAddress("VerifierLib"),
          },
        },
      },
    },
  },
};
