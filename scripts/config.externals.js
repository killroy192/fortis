module.exports = {
  hardhat: {
    verifier: ethers.ZeroAddress,
    streamId: ethers.ZeroAddress,
    datafeed: ethers.ZeroAddress,
    linkNativeFeed: ethers.ZeroAddress,
    linkToken: ethers.ZeroAddress,
    registry: ethers.ZeroAddress,
  },
  "arbitrum-sepolia": {
    verifier: "0x2ff010DEbC1297f19579B4246cad07bd24F2488A",
    streamId:
      "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b",
    datafeed: "0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165",
    linkNativeFeed: "0x3ec8593F930EA45ea58c968260e6e9FF53FC934f",
    linkToken: "0xb1d4538b4571d411f07960ef2838ce337fe1e80e",
    registry: "0x8194399b3f11fca2e8ccefc4c9a658c61b8bf412",
  },
};
