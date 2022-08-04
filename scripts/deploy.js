const hre = require("hardhat");
const { getProteinFactory } = require("../helpers/web3");

async function main() {
  const ProteinQuery = await getProteinFactory(hre);
  const proteinQuery = await ProteinQuery.deploy();

  await proteinQuery.deployed();
  console.log(`Protein Query contract has been deployed!`);
  console.log(`Contract address: ${proteinQuery.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
