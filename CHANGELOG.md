#### 1.1.0 (2022-08-03)

- MAJOR IMPROVEMENT: An algorithm inspired by the blast protocol has been implemented; massively improving speed for queries. It has a similar approach of cutting all sequences into short segments, but we puzzle it together only for the segments that match the query string exactly. Unlike blast, where we use a scoring matrix, where some versions allow for gaps to be present between the short sequences and where similar sequences are also included in the search results (if they score a high enough ranking based on an E-value). This will probably be implemented at some point in the future.
- A CRUD for Seeds has been added. This enables us to store all possible n-sized segments present in all imported protein strings (where n = a small number like 3, 4, 5 or 6). Currently it only has been tested with 3 letter words, but ideally a longer word would improve the algorithm even more.
- Created a proteins.config.js file and removed the .env file. Now the contract address has to be configured in this file (including more options like setting the batch size for importing or seed size for the seed CRUD).
- The Owner contract has more functionality now. For instance, we're now able to create and remove admins allowing others to interact with the C, U and D of the CRUDs.
- Fixed the gas used-bug in the addProteins script. Now it waits for the transaction receipt before trying to calculate the gas usage.
- The protein .txt files are now in the subfolder ./datasets/proteins/.
- Seed structs of different sizes have been added to ./datasets/seeds/.
- An insertSeeds.js script has been added (should be run after deployment in order for the new algorithm to work).
- Renamed the addProteins script to insertProteins, queryProtein to naiveQuery, getProteinCount to proteinCount and getProteinAtIndex to proteinAtIndex.
- Generalized the insertion script (in ./helper/insertion.js) and made insertSeeds and insertProteins derivatives.
- More tasks have been added (see hardhat.config.js).
- Restructured all contracts and set the Solidity version to 0.8.12.
- Refactored code.
- Updated README.md (but needs work).

#### 1.0.2 (2022-08-02)

- Created an insertProteins function in the ProteinCrud contract, we can now add multiple proteins at once.
- Owner contract added. The ProteinCrud contract inherits its functionality, enabling it to prevent addresses, other than the owner, from accessing sensitive data/functions.
- Added the Genesis network to the hardhat config file.
- Revisited the addProteins.js script, it now shows more detailed analytics when adding proteins.

#### 1.0.1 (2022-08-01)

- Renamed PDBID to ID.
- Added more datasets, of sizes 10, 100, 1000, 5000, 10000 and 104059.
- More tasks added (getProteinCount, getProtein, getProteinAtIndex found in the hardhat.config.js file).
- Added an extra parameter to the insertProtein function (bypassRevert) to prevent transactions to be reverted when adding a protein that already exists.

#### 1.0.0 (2022-08-01)

- Added Solidity Contracts.
- Two scripts for contract deployment and protein insertion.
- One task for querying the protein strings based on PDBID or SEQUENCE.
- A dataset of 100 proteins.
