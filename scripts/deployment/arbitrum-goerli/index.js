const deploy = require("../deploy");
const upgradeOracle = require("../upgradeOracle");
const config = require("./config");

async function main() {
  const lock = await deploy(config);

  return upgradeOracle(lock, "0xd14838A68E8AFBAdE5efb411d5871ea0011AFd28");
}

main();
