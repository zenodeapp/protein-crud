//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

const { contractName, contractAddress } = require("../proteins.config");

const getProteinContract = async (hre) => {
  const contract = await hre.ethers.getContractAt(
    contractName,
    contractAddress
  );

  return contract;
};

const getProteinFactory = async (hre) => {
  const Factory = await hre.ethers.getContractFactory(contractName);

  return Factory;
};

module.exports = { getProteinContract, getProteinFactory };
