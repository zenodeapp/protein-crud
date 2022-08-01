const fs = require("fs/promises");
const hre = require("hardhat");

//Check the ./datasets folder to see which datasets are available.
const DATASET_TO_IMPORT = "datasets/protein_structs_1000.txt";

// How many proteins inserted per transaction
const BATCH_SIZE = 50;

// Normally, already imported NFTs will return with an error stating it already exists, but setting BYPASS_REVERT to true won't result in an error message.
// Do have in mind that this consumes more gas, for the tx doesn't get reverted!
// Adviced to use this only for testing purposes, if you know what you're doing or if you don't care about the extra gas.
// This parameter will probably be removed in the final version of the contract.
const BYPASS_REVERT = false;

async function main() {
  const res = await fs.readFile(DATASET_TO_IMPORT, {
    encoding: "utf8",
  });

  let totalGas = 0;
  const proteins = JSON.parse(res);
  const proteinsLength = proteins.length;
  const amountTransactions = Math.ceil(proteinsLength / BATCH_SIZE);

  const proteinQuery = await hre.ethers.getContractAt(
    "ProteinQuery",
    process.env.CONTRACT_ADDRESS
  );

  console.log(`Amount to add: ${proteinsLength} proteins.`);
  console.log(
    `Amount of transactions necessary: ${amountTransactions} transactions.`
  );
  console.log(`Batch size: ${BATCH_SIZE} proteins per transaction.\n`);

  console.time("timer");
  for (let i = 0; i < amountTransactions; i++) {
    const batch = proteins.filter(
      (_, j) => j >= i * BATCH_SIZE && j < (i + 1) * BATCH_SIZE
    );

    const insertProteins = await proteinQuery.insertProteins(
      batch.map((protein) => protein.nftId),
      batch.map((protein) => protein.id),
      batch.map((protein) => protein.sequence),
      BYPASS_REVERT
    );

    const gasCost = parseInt(insertProteins.gasLimit);
    totalGas = totalGas + gasCost;

    console.log(
      `${i + 1}/${amountTransactions}\t${
        i == amountTransactions - 1 ? proteinsLength : (i + 1) * BATCH_SIZE
      }/${proteinsLength}\t${gasCost}/${totalGas}`
    );
  }
  console.timeEnd("timer");

  const avgPerTransaction = totalGas / amountTransactions;

  console.log(
    `\nAll ${proteinsLength} proteins added using ${totalGas} gas across ${amountTransactions} transactions in total!`
  );
  console.log(
    `An average of ${
      Math.round(avgPerTransaction * 100) / 100
    } gas per transaction for ${BATCH_SIZE} proteins, making it ~${
      Math.round((avgPerTransaction / BATCH_SIZE) * 100) / 100
    } gas per protein.`
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
