const fs = require("fs/promises");
const hre = require("hardhat");

//Check the ./datasets folder to see which datasets are available.
const DATASET_TO_IMPORT = "datasets/protein_structs_1000.txt";

// Normally, already imported NFTs will return with an error stating it already exists, but setting SKIP_EXISTING to true won't result in an error message.
// Do have in mind that this consumes more gas, for the tx doesn't get reverted!
// Adviced to use this only for testing purposes. This parameter will probably be removed in the final version of the contract.
const SKIP_EXISTING = true;

async function main() {
  const res = await fs.readFile(DATASET_TO_IMPORT, {
    encoding: "utf8",
  });

  const proteins = JSON.parse(res);
  const proteinsLength = proteins.length;

  const proteinQuery = await hre.ethers.getContractAt(
    "ProteinQuery",
    process.env.CONTRACT_ADDRESS
  );

  let totalGas = 0;

  console.log(`Adding first ${proteinsLength} proteins...`);
  for (let i = 0; i < proteinsLength; i++) {
    const insertProtein = await proteinQuery.insertProtein(
      proteins[i].nftId,
      proteins[i].id,
      proteins[i].sequence,
      SKIP_EXISTING
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
