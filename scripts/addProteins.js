const fs = require("fs/promises");
const hre = require("hardhat");

async function main() {
  const proteinQuery = await hre.ethers.getContractAt(
    "ProteinQuery",
    process.env.CONTRACT_ADDRESS
  );

  const res = await fs.readFile("protein_structs_1.txt", {
    encoding: "utf8",
  });
  const proteins = JSON.parse(res);
  const proteinsLength = proteins.length;
  let totalGas = 0;

  console.log(`Adding first ${proteinsLength} proteins...`);
  for (let i = 0; i < proteinsLength; i++) {
    const insertProtein = await proteinQuery.insertProtein(
      proteins[i].nftId,
      proteins[i].pdbId,
      proteins[i].sequence
    );
    console.log(`${i + 1}/${proteinsLength}`);
    totalGas = totalGas + parseInt(insertProtein.gasLimit);
  }

  console.log(`All ${proteinsLength} proteins added using ${totalGas} gas!`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
