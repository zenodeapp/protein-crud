//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const insertion = require("../helpers/insertion");

const {
  totalProteinAmount,
  seedsPerBatch,
  bypassRevert,
  seedSize,
} = require("../proteins.config");

async function main() {
  insertion(
    `datasets/seeds/seed_${seedSize}_structs_${totalProteinAmount}.txt`,
    seedsPerBatch,
    "seed",
    async (contract, i, data, keys) => {
      const seeds = keys.slice(i * seedsPerBatch, (i + 1) * seedsPerBatch);
      const seedsPositions = seeds.map((seed) => data[seed]);

      const insertSeeds = await contract.insertSeeds(
        seeds,
        seedsPositions,
        bypassRevert
      );

      return insertSeeds;
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
