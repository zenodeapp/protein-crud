//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const fs = require("fs/promises");
const { toBillion } = require("./math");
const { getProteinContract } = require("./web3");

module.exports = async (file, perBatch, type, callback) => {
  const res = await fs.readFile(file, { encoding: "utf8" });

  const data = JSON.parse(res);
  const keys = Object.keys(data);
  const dataLength = keys.length;
  const amountTransactions = Math.ceil(dataLength / perBatch);

  console.log(`Amount to add: ${dataLength} ${type}s.`);
  console.log(
    `Amount of transactions necessary: ${amountTransactions} transactions.`
  );
  console.log(`Batch size: ${perBatch} ${type}s per transaction.\n`);

  const contract = await getProteinContract(hre);

  console.time("timer");
  let totalGas = 0;
  for (let i = 0; i < amountTransactions; i++) {
    const insertCall = await callback(contract, i, data, keys);

    const receipt = await insertCall.wait();
    const gasCost = receipt.gasUsed;
    totalGas = totalGas + parseInt(gasCost);

    console.log(
      `${i + 1}/${amountTransactions}\t${
        i == amountTransactions - 1 ? dataLength : (i + 1) * perBatch
      }/${dataLength}\t${gasCost}/${totalGas}`
    );
  }
  console.timeEnd("timer");

  const avgPerTransaction = totalGas / amountTransactions;

  console.log(
    `\nAll ${dataLength} ${type}s added using ${totalGas} gas (${toBillion(
      totalGas,
      3
    )} B) across ${amountTransactions} transactions in total!`
  );
  console.log(
    `An average of ${
      Math.round(avgPerTransaction * 100) / 100
    } gas per transaction for ${perBatch} ${type}s, making it ~${
      Math.round((avgPerTransaction / perBatch) * 100) / 100
    } gas per ${type}.`
  );
};
