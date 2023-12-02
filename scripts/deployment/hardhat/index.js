const deploy = require("../deploy");
const upgrades = require("../upgrades");
const config = require("./config");

async function main() {
  const lock = await deploy(config);

  return upgrades(lock, "0xb1d4538b4571d411f07960ef2838ce337fe1e80e");
}

main();
