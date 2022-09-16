//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const batchCrud = require("../../helpers/batchCrud");
const { getIndexerSeedContract } = require("../../helpers/web3");
const hre = require("hardhat");

const {
  bypassRevert,
  hardDelete,
  manyScripts,
} = require("../../proteins.config");

async function main() {
  batchCrud(
    await getIndexerSeedContract(hre),
    manyScripts.files.wildcardsDeleteMany,
    manyScripts.wildcardsPerBatch,
    ["wildcard", "wildcards"],
    async (contract, i, _, keys) => {
      const deleteManyWildcards = await contract.deleteManyWildcards(
        keys.slice(
          i * manyScripts.wildcardsPerBatch,
          (i + 1) * manyScripts.wildcardsPerBatch
        ),
        hardDelete,
        bypassRevert
      );

      return deleteManyWildcards;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
