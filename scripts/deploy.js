const hre = require("hardhat");

async function main() {
  const ProteinQuery = await hre.ethers.getContractFactory("ProteinQuery");
  const proteinQuery = await ProteinQuery.deploy();

  await proteinQuery.deployed();
  console.log(`Protein Query contract has been deployed!`);
  console.log(`Contract address: ${proteinQuery.address}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
