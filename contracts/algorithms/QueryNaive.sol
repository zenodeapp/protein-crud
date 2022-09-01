pragma solidity ^0.8.12;
import '../../libraries/Strings.sol';
import '../../libraries/Structs.sol';
import '../indexers/IndexerProtein.sol';
import './QueryAbstract.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

/* QUERYING - "NAIVE" APPROACH */
// The naive approach of querying. Works okay with smaller datasets, but takes a lot of time when it has to go through a bunch.
// Proteins are queried by going through every single one of them, step-by-step (it checks whether the query is contained using string comparison).
contract QueryNaive is QueryAbstract {
  using Strings for string;

  struct QueryInput {
    string id;
    string sequence;
    string fasta;
  }

  struct QueryOptions {
    uint limit;
    bool caseSensitive;
  }

  function queryNftIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputNftIds memory result) {
    return naiveAlgorithm(queryInput, queryOptions, indexerProteinAddress);
  }

  function queryProteins(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputProteinStructs memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryProteins(_result, indexerProteinAddress);
  }

  function queryIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIds memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryIds(_result, indexerProteinAddress);
  }

  function querySequences(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputSequences memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _querySequences(_result, indexerProteinAddress);
  }

  function queryIpfsHashes(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIpfsHashes memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryIpfsHashes(_result, indexerProteinAddress);
  }

  function queryFastaMetadata(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputFastaMetadata memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryFastaMetadata(_result, indexerProteinAddress);
  }

  function queryFastaSequences(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputFastaSequences memory result) {
    Structs.QueryOutputNftIds memory _result = queryNftIds(queryInput, queryOptions, indexerProteinAddress);
    return _queryFastaSequences(_result, indexerProteinAddress);
  }

  function naiveAlgorithm(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress) 
  internal view returns(Structs.QueryOutputNftIds memory result) {
    bool idIsEmpty = bytes(queryInput.id).length == 0;
    bool sequenceIsEmpty = bytes(queryInput.sequence).length == 0;
    bool fastaIsEmpty = bytes(queryInput.fasta).length == 0;

    require(!idIsEmpty || !sequenceIsEmpty || !fastaIsEmpty, "Query can't be empty.");
    
    IndexerProtein indexerProtein = IndexerProtein(indexerProteinAddress);
    uint proteinCount = indexerProtein.getProteinCount();
    require(proteinCount > 0, "In order to query in this manner, proteins have to be inserted first.");

    uint[] memory _nftIds = new uint[](proteinCount);

    if(!queryOptions.caseSensitive) {
      if(!idIsEmpty) queryInput.id = queryInput.id.toUpper();
      if(!sequenceIsEmpty) queryInput.sequence = queryInput.sequence.toUpper();
      if(!fastaIsEmpty) queryInput.fasta = queryInput.fasta.toUpper();
    }

    for(uint i = 0; i < proteinCount; i++) {
      Structs.ProteinStruct memory _protein = indexerProtein.getProteinStructAtIndex(i);

      bool idCondition = idIsEmpty || queryInput.id.contains(queryOptions.caseSensitive ? _protein.id : _protein.id.toUpper(), true);
      bool fastaCondition = fastaIsEmpty || queryInput.fasta.compare(queryOptions.caseSensitive ? _protein.fastaMetadata : _protein.fastaMetadata.toUpper());
      bool sequenceCondition = sequenceIsEmpty || queryInput.sequence.contains(_protein.sequence, true);

      bool condition = idCondition && fastaCondition && sequenceCondition;

      if(condition) {
        _nftIds[result.proteinCount] = _protein.nftId;
        result.proteinCount++;

        if(result.proteinCount == queryOptions.limit) break;
      }
    }

    result.nftIds = new uint[](result.proteinCount);
    for(uint i = 0; i < result.proteinCount; i++) result.nftIds[i] = _nftIds[i];
  }
}