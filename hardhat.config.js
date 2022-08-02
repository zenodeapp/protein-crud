require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: __dirname + "/.env" });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "localhost",
  networks: {
    hardhat: { gas: 2000000000, blockGasLimit: 2000000000 },
    localhost: { url: "http://127.0.0.1:8545", timeout: 100000000 },
    genesisd: {
      url: "http://23.88.68.53:8545",
      // gasPrice: 2000000000,
      // gas: 2000000000,
      // blockGasLimit: 2000000000,
      // allowUnlimitedContractSize: true,
      chainId: 29,
      accounts: [],
      timeout: 100000000,
    },
  },
  mocha: {
    timeout: 100000000,
  },
};

task(
  "queryProtein",
  "Get all NFTs matching id or sequence with the given query."
)
  .addOptionalParam("sequence", "The sequence query.", "")
  .addOptionalParam("id", "The PDBID/ACCESSION query.", "")
  .addOptionalParam(
    "exclusive",
    "Exclusive would mean that both query restrictions must be true, else one or the other has to be true.",
    "false"
  )
  .setAction(async (taskArgs, hre) => {
    const { id, sequence, exclusive } = taskArgs;

    const contract = await hre.ethers.getContractAt(
      "ProteinQuery",
      process.env.CONTRACT_ADDRESS
    );

    const result = await contract.queryProtein(id, sequence, eval(exclusive));

    console.log(result.proteins);
    console.log(
      `${result.proteinsFound} results found matching query {sequence: "${sequence}", id: "${id}", exclusive: ${exclusive}}.`
    );
  });

task("getProteinCount", "How many proteins are included in storage.").setAction(
  async (_, hre) => {
    const contract = await hre.ethers.getContractAt(
      "ProteinQuery",
      process.env.CONTRACT_ADDRESS
    );

    const result = await contract.getProteinCount();

    console.log(result);
  }
);

task("getProtein", "Returns the protein for the given NFT ID.")
  .addParam("nft", "The NFT ID.", "")
  .setAction(async (taskArgs, hre) => {
    const { nft } = taskArgs;
    const contract = await hre.ethers.getContractAt(
      "ProteinQuery",
      process.env.CONTRACT_ADDRESS
    );

    const result = await contract.getProtein(nft);

    console.log(result);
  });

task("getProteinAtIndex", "Returns the NFT ID at the given index.")
  .addParam("index", "The index value.", "")
  .setAction(async (taskArgs, hre) => {
    const { index } = taskArgs;
    const contract = await hre.ethers.getContractAt(
      "ProteinQuery",
      process.env.CONTRACT_ADDRESS
    );

    const result = await contract.getProteinAtIndex(index);

    console.log(result);
  });
