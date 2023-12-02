const deploy = require("../deploy");
const upgradeOracle = require("../upgradeOracle");
const config = require("./config");

async function main() {
  const lock = await deploy(config);

  return upgradeOracle(lock, "0xb1d4538b4571d411f07960ef2838ce337fe1e80e");
}

main();
