pragma solidity ^0.8.12;
import './CrudSeed.sol';
import '../libraries/Structs.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

contract IndexerSeed is CrudSeed {
  // For instance an indexer group: 'Homo Sapiens', with an ID of 2 would be the second Indexer for this protein type.
  Structs.IndexerStruct public indexer;

  // What is the length for each seed contained in this contract?
  uint public seedSize;

  constructor(string memory _indexerGroup, uint _indexerId, uint _seedSize) {
    setIndexer(_indexerGroup, _indexerId);
    setSeedSize(_seedSize);
  }

  function setIndexer(string memory _indexerGroup, uint _indexerId) public onlyAdmin returns(Structs.IndexerStruct memory) {
    indexer = Structs.IndexerStruct(_indexerGroup, _indexerId);

    return indexer;
  }

  function setSeedSize(uint _seedSize) public onlyAdmin returns(uint) {
    seedSize = _seedSize;
    return seedSize;
  }

  function getIndexerInfo() public view returns(string memory indexerGroup, uint indexerId, uint seedCount, uint _positionCount, uint _detectablePositions, uint _seedSize) {
    return (indexer.group, indexer.id, getSeedCount(), seedSize, positionCount, detectablePositions);
  }
}