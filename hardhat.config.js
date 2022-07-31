require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: __dirname + "/.env" });

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "localhost",
  networks: {
    hardhat: { gas: 2000000000, blockGasLimit: 2000000000 },
    localhost: { url: "http://127.0.0.1:8545", timeout: 100000000 },
  },
};

task(
  "queryProtein",
  "Get all NFTs matching pdb id or sequence with the given query."
)
  .addOptionalParam("sequence", "The sequence query.", "")
  .addOptionalParam("pdbid", "The pdbid query.", "")
  .addOptionalParam(
    "exclusive",
    "Exclusive would mean that both query restrictions must be true, else one or the other has to be true.",
    "false"
  )
  .setAction(async (taskArgs, hre) => {
    const { pdbid, sequence, exclusive } = taskArgs;

    const contract = await hre.ethers.getContractAt(
      "ProteinQuery",
      process.env.CONTRACT_ADDRESS
    );

    const result = await contract.queryProtein(
      pdbid,
      sequence,
      eval(exclusive)
    );

    console.log(result.proteins);
    console.log(
      `${result.proteinsFound} results found matching query {sequence: "${sequence}", pdbid: "${pdbid}", exclusive: ${exclusive}}.`
    );
  });
