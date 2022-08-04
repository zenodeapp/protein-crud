pragma solidity ^0.8.12;
import './Owner.sol';
import './QueryHelpers.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

//Basis from Rob Hitchens's UserCrud, found on: https://bitbucket.org/rhitchens2/soliditycrud/src/master/
//Updated to solidity ^0.8.0 and edited/extended for seed strings by Tousuke.
contract SeedCrud is Owner, QueryHelpers {
  struct SeedStruct {
    string seed;
    SeedPositionStruct[] positions;
    uint index;
  }

  struct SeedPositionStruct {
    uint nftId;
    uint position;
  }
  
  string[] internal seedIndex;
  mapping(string => SeedStruct) internal seedStructs;

  uint public seedSize = 3;
  uint public seedStep = 3;

  event LogNewSeed (string indexed seed, uint index, SeedPositionStruct[] positions);
  event LogUpdateSeed (string indexed seed, uint index, SeedPositionStruct[] positions);
  event LogDeleteSeed (string indexed seed, uint index);

  function insertSeed(string memory seed, SeedPositionStruct[] memory positions, bool bypassRevert) public onlyAdmin returns(uint index) {
    bool exists = isSeed(seed);
    
    if(bypassRevert && exists) {
      return seedIndex.length - 1;
    } else {
      require(!exists, "This seed already exists and can't be inserted twice. Update its properties instead.");
    }

    seedIndex.push(seed);
    seedStructs[seed].seed = seed;
    seedStructs[seed].index = seedIndex.length - 1;
    insertSeedPositions(seed, positions);

    emit LogNewSeed(seed, seedStructs[seed].index, positions);

    return seedIndex.length-1;
  }

  function insertSeeds(string[] memory seeds, SeedPositionStruct[][] memory positions, bool bypassRevert) public onlyAdmin returns(uint index) {
    for(uint i = 0; i < seeds.length; i++) {
      insertSeed(seeds[i], positions[i], bypassRevert);
    }

    return seedIndex.length-1;
  }
  
  function updateSeedPositions(string memory seed, SeedPositionStruct[] memory positions) public onlyAdmin returns(bool success) {
    require(isSeed(seed), "Seed could not be found in the database."); 
    
    delete seedStructs[seed].positions;
    insertSeedPositions(seed, positions);
    
    SeedStruct memory _seedStruct = seedStructs[seed];
    emit LogUpdateSeed(seed, _seedStruct.index, _seedStruct.positions);

    return true;
  }

  function updateSeedSize(uint size) public onlyAdmin returns(uint) {
    seedSize = size;
    return seedSize;
  }

  function updateSeedStep(uint step) public onlyAdmin returns(uint) {
    seedStep = step;
    return seedStep;
  }

  function insertSeedPositions(string memory seed, SeedPositionStruct[] memory positions) private onlyAdmin {
    for(uint i = 0; i < positions.length; i++) {
      insertSeedPosition(seed, positions[i]);
    }
  }

  function insertSeedPosition(string memory seed, SeedPositionStruct memory position) private onlyAdmin {
    seedStructs[seed].positions.push(position);
  }

  function deleteSeed(string memory seed) public onlyOwner returns(uint index) {
    require(isSeed(seed), "Seed could not be found in the database."); 
    
    uint rowToDelete = seedStructs[seed].index;
    string memory keyToMove = seedIndex[seedIndex.length - 1];

    seedIndex[rowToDelete] = keyToMove;
    seedStructs[keyToMove].index = rowToDelete; 
    seedIndex.pop();

    emit LogDeleteSeed(seed, rowToDelete);
    emit LogUpdateSeed(keyToMove, rowToDelete, seedStructs[keyToMove].positions);

    return rowToDelete;
  }

  function getSeed(string memory seed) public view returns(SeedPositionStruct[] memory positions, uint index) {
    require(isSeed(seed), "Seed could not be found in the database."); 
    
    SeedStruct memory _seedStruct = seedStructs[seed];
    return(
      _seedStruct.positions, 
      _seedStruct.index);
  }

  function getSeedPositions(string memory seed) internal view returns (SeedPositionStruct[] memory) {
    return seedStructs[seed].positions;
  }

  function getAllSeedPositions(string[] memory seeds) internal view returns (SeedPositionStruct[][] memory positions) {
    positions = new SeedPositionStruct[][](seeds.length);

    for(uint i = 0; i < seeds.length; i++) {
      SeedPositionStruct[] memory _positions = getSeedPositions(seeds[i]);
      positions[i] = _positions;
    }
  }

  function isSeed(string memory seed) public view returns(bool isIndeed) {
    if(seedIndex.length == 0) return false;

    return (compareStrings(seedIndex[seedStructs[seed].index], seed));
  }

  function seedCount() public view returns(uint count) {
    return seedIndex.length;
  }

  function seedAtIndex(uint index) public view returns(string memory seed) {
    return seedIndex[index];
  }
}
