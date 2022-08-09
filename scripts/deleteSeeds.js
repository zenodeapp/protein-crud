//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const insertion = require("../helpers/insertion");

const { totalProteinAmount, seedSize } = require("../proteins.config");

async function main() {
  insertion(
    `datasets/seeds/seed_${seedSize}_structs_${totalProteinAmount}.txt`,
    1,
    "seed",
    async (contract, i, _, keys) => {
      const seedCount = await contract.seedCount();

      if (seedCount == 1) {
        return false;
      }

      const seeds = keys.slice(i, i + 1);
      const seed = seeds[0];
      const isSeed = await contract.isSeed(seed);
      if (isSeed) {
        const deleteSeed = await contract.deleteSeed(seed);
        return deleteSeed;
      } else {
        return false;
      }
    }
  );
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
