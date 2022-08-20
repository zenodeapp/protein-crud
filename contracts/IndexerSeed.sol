pragma solidity ^0.8.12;
import './CrudSeed.sol';
import './CrudWildcard.sol';
import '../libraries/Structs.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

contract IndexerSeed is CrudSeed, CrudWildcard {
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

  function repeatChar(bytes1 char, uint count) private pure returns(string memory) {
    bytes memory bStr = new bytes(count);

    for(uint i = 0; i < count; i++) bStr[i] = char;

    return string(bStr);
  }

  function getShortQueryPositions(string memory shortQuery, uint _proteinCount, uint _seedSize) public view returns (Structs.QueryOutputPositions memory queryOutputPositions) {
    queryOutputPositions.positions = new Structs.SeedPositionStruct[][](1);

    string memory wildcardPart = repeatChar("*", _seedSize - bytes(shortQuery).length);
    string memory wildcardHead = string.concat(shortQuery, wildcardPart);
    string memory wildcardTail = string.concat(wildcardPart, shortQuery);

    if(!isWildcard(wildcardHead) && !isWildcard(wildcardTail)) {
      queryOutputPositions.emptyFound = true;
      queryOutputPositions.returnAll = false;
      return queryOutputPositions;
    }

    Structs.WildcardStruct[2] memory _wildcardStructs = [getWildcardStruct(wildcardHead), getWildcardStruct(wildcardTail)];
    Structs.SeedPositionStruct[] memory _positions = new Structs.SeedPositionStruct[](_wildcardStructs[0].count + _wildcardStructs[1].count);
    bool[] memory addedProteins = new bool[](_proteinCount);

    uint wildcardPointer = 0;
    
    for (uint i = 0; i < _wildcardStructs.length; i++) {
      for (uint j = 0; j < _wildcardStructs[i].seeds.length; j++) {
        Structs.SeedPositionStruct[] memory wildcardPositions = getSeedPositions(_wildcardStructs[i].seeds[j]);

        for (uint k = 0; k < wildcardPositions.length; k++) {
          if(!addedProteins[wildcardPositions[k].nftId - 1]) {
            _positions[wildcardPointer] = wildcardPositions[k];
            wildcardPointer++;

            addedProteins[wildcardPositions[k].nftId - 1] = true;
          }
        }
      }
    }

    queryOutputPositions.emptyFound = false;
    queryOutputPositions.returnAll = _positions.length == 0;

    queryOutputPositions.positions[0] = new Structs.SeedPositionStruct[](wildcardPointer);
    for(uint i = 0; i < wildcardPointer; i++) queryOutputPositions.positions[0][i] = _positions[i];

    return queryOutputPositions;
  }

  function getQueryPositions(string[] memory seeds, bool returnOnEmpty) public view returns (Structs.QueryOutputPositions memory queryOutputPositions) {
    queryOutputPositions.positions = new Structs.SeedPositionStruct[][](seeds.length);
    queryOutputPositions.returnAll = true;

    Structs.SeedPositionStruct[] memory _positions;
    
    for(uint i = 0; i < seeds.length; i++) {
      if(isWildcard(seeds[i])) {
        Structs.WildcardStruct memory wildcardStruct = getWildcardStruct(seeds[i]);
        
        _positions = new Structs.SeedPositionStruct[](wildcardStruct.count);

        uint wildcardPointer = 0;

        for (uint j = 0; j < wildcardStruct.seeds.length; j++) {
          Structs.SeedPositionStruct[] memory _wildcardPositions = getSeedPositions(wildcardStruct.seeds[j]);

          for (uint k = 0; k < _wildcardPositions.length; k++) {
            _positions[wildcardPointer] = _wildcardPositions[k];
            wildcardPointer++;
          }
        }

        queryOutputPositions.returnAll = queryOutputPositions.returnAll && _positions.length == 0;
      } else {
        _positions = getSeedPositions(seeds[i]);
        queryOutputPositions.returnAll = false;

        if(returnOnEmpty && _positions.length == 0) {
          queryOutputPositions.emptyFound = true;
          break;
        }
      }

      queryOutputPositions.positions[i] = _positions;
    }
  }

  function getIndexerInfo() public view returns(string memory indexerGroup, uint indexerId, uint seedCount, uint _seedSize, uint _positionCount, uint _detectablePositions) {
    return (indexer.group, indexer.id, getSeedCount(), seedSize, positionCount, detectablePositions);
  }
}