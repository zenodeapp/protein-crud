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
