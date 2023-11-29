module.exports = [
  {
    contract: "RequestLib",
  },
  {
    contract: "RequestsManager",
  },
  {
    contract: "MockOracle",
    args: [
      (deploymentLock) => deploymentLock.RequestsManager.addr,
      "0x00027bbaff688c906a3e20a34fe951715d1018d262a5b66e38eda027a674cd1b",
      "0xd30e2101a97dcbAeBCBC04F14C3f624E67A35165",
      5,
    ],
    deployerOptions: {
      libs: {
        RequestLib: (deploymentLock) => deploymentLock.RequestLib.addr,
      },
    },
  },
  {
    contract: "MockConsumer",
    args: [(deploymentLock) => deploymentLock.MockOracle.addr],
  },
];
