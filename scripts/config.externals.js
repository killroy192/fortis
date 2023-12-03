module.exports = {
  hardhat: {
    verifier: ethers.ZeroAddress,
    streamId: ethers.ZeroAddress,
    datafeed: ethers.ZeroAddress,
  },
  "arbitrum-goerli": {
    verifier: "0xcB1241Fdf26501fA7A2d47d841dcF72C3CAa9dCe",
    streamId:
      "0x00029584363bcf642315133c335b3646513c20f049602fc7d933be0d3f6360d3",
    datafeed: "0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165", // doesn't work
  },
  "arbitrum-sepolia": {
    verifier: "0x2ff010DEbC1297f19579B4246cad07bd24F2488A",
    streamId:
      "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b",
    datafeed: "0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165",
  },
};
