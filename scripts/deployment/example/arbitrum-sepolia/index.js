const deploy = require("../../deploy");
const upgrades = require("../upgrades");
const config = require("./config");

async function main() {
  const lock = await deploy(config);

  return upgrades(lock);
}

main();
