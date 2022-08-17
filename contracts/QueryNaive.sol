pragma solidity ^0.8.12;
import '../libraries/Strings.sol';
import '../libraries/Structs.sol';
import './IndexerProtein.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

/* QUERYING - "NAIVE" APPROACH */
// The naive approach of querying. Works okay with smaller datasets, but takes a lot of time when it has to go through a bunch.
// Proteins are queried by going through every single one of them, step-by-step (it checks whether the query is contained using string comparison).
contract QueryNaive {
  using Strings for string;

  struct QueryOptions {
    uint limit;
    bool caseSensitive;
  }

  function queryNftIdsById(string memory idQuery, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryResultNftIds memory result) {
    return naiveAlgorithm(idQuery, queryOptions, indexerProteinAddress);
  }

  function queryProteinsById(string memory idQuery, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryResultProteinStructs memory result) {
    Structs.QueryResultNftIds memory _result = queryNftIdsById(idQuery, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.proteins = IndexerProtein(indexerProteinAddress).getManyProteinStructs(_result.nftIds);
  }

  function naiveAlgorithm(string memory idQuery, QueryOptions memory queryOptions, address indexerProteinAddress) 
  internal view returns(Structs.QueryResultNftIds memory result) {
    uint wordSize = bytes(idQuery).length;
    require(wordSize != 0, "Query can't be empty.");
    
    IndexerProtein indexerProtein = IndexerProtein(indexerProteinAddress);
    uint proteinCount = indexerProtein.getProteinCount();
    require(proteinCount > 0, "In order to query in this manner, proteins have to be inserted first.");

    uint[] memory _nftIds = new uint[](proteinCount);

    if(!queryOptions.caseSensitive) idQuery = idQuery.toUpper();

    for(uint i = 0; i < proteinCount; i++) {
      Structs.ProteinStruct memory _protein = indexerProtein.getProteinStructAtIndex(i);
    
      if(idQuery.contains(queryOptions.caseSensitive ? _protein.id : _protein.id.toUpper())) {
          _nftIds[result.proteinCount] = _protein.nftId;
          result.proteinCount++;

          if(result.proteinCount == queryOptions.limit) break;
      }
    }

    result.nftIds = new uint[](result.proteinCount);
    for(uint i = 0; i < result.proteinCount; i++) result.nftIds[i] = _nftIds[i];
  }
}