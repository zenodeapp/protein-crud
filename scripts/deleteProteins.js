//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const insertion = require("../helpers/insertion");

const { totalProteinAmount } = require("../proteins.config");

async function main() {
  insertion(
    `datasets/proteins/protein_structs_${totalProteinAmount}.txt`,
    1,
    "protein",
    async (contract, i, data) => {
      const proteinCount = await contract.proteinCount();

      if (proteinCount == 1) {
        return false;
      }

      const nftId = data[i].nftId;

      const isProtein = await contract.isProtein(nftId);

      if (isProtein) {
        const deleteProtein = await contract.deleteProtein(nftId);
        return deleteProtein;
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
