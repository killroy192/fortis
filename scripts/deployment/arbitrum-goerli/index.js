const deploy = require("../deploy");
const upgrades = require("../upgrades");
const config = require("./config");

async function main() {
  const lock = await deploy(config);

  return upgrades(lock, "0xd14838A68E8AFBAdE5efb411d5871ea0011AFd28");
}

main();
