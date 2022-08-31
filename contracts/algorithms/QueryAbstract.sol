pragma solidity ^0.8.12;
import '../../libraries/Structs.sol';
import '../indexers/IndexerProtein.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

contract QueryAbstract {
  function _queryProteins(Structs.QueryOutputNftIds memory _result, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputProteinStructs memory result) {
    result.proteinCount = _result.proteinCount;
    result.proteins = IndexerProtein(indexerProteinAddress).getManyProteinStructs(_result.nftIds);
  }

  function _queryIds(Structs.QueryOutputNftIds memory _result, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputIds memory result) {
    result.proteinCount = _result.proteinCount;
    result.ids = IndexerProtein(indexerProteinAddress).getManyProteinIds(_result.nftIds);
  }

  function _querySequences(Structs.QueryOutputNftIds memory _result, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputSequences memory result) {
    result.proteinCount = _result.proteinCount;
    result.sequences = IndexerProtein(indexerProteinAddress).getManyProteinSequences(_result.nftIds);
  }

  function _queryIpfsHashes(Structs.QueryOutputNftIds memory _result, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputIpfsHashes memory result) {
    result.proteinCount = _result.proteinCount;
    result.ipfsHashes = IndexerProtein(indexerProteinAddress).getManyProteinIpfsHashes(_result.nftIds);
  }

  function _queryFastaMetadata(Structs.QueryOutputNftIds memory _result, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputFastaMetadata memory result) {
    result.proteinCount = _result.proteinCount;
    result.fastaMetadata = IndexerProtein(indexerProteinAddress).getManyProteinFastaMetadata(_result.nftIds);
  }

  function _queryFastaSequences(Structs.QueryOutputNftIds memory _result, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputFastaSequences memory result) {
    result.proteinCount = _result.proteinCount;
    result.fastaSequences = IndexerProtein(indexerProteinAddress).getManyProteinFastaSequences(_result.nftIds);
  }
}