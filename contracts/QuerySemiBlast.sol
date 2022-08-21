pragma solidity ^0.8.12;
import '../libraries/Strings.sol';
import '../libraries/Structs.sol';
import './IndexerProtein.sol';
import './IndexerSeed.sol';

import '../node_modules/hardhat/console.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

/* QUERYING - "SEMI-BLAST" APPROACH */
// Inspired by the first couple steps of the Blast algorithm; leaning mostly on the lookup table.
// Rather than having 'probable' outcomes using scoring matrices and E-values we search for 'exact' matches.
contract QuerySemiBlast {
  using Strings for string;
  string[20] aminoAcids;

  struct QueryInput {
    string sequence;
  }

  struct QueryOptions {
    uint seedSize;
    uint limit;
    bool caseSensitive;
  }

  struct PuzzleData {
    Structs.SeedPositionStruct[][] positions;
    uint[] pointers;
    uint proteinCount;
    uint seedSize;
    uint seedTailOverlap;
    uint limit;
  }

  constructor() {
    aminoAcids = [
      "A", "R", "N", "D", 
      "C", "Q", "E", "G", 
      "H", "I", "L", "K", 
      "M", "F", "P", "S", 
      "T", "W", "Y", "V"];
  }

  function queryProteins(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputProteinStructs memory result) {
    Structs.QueryOutputNftIds memory _result = semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.proteins = IndexerProtein(indexerProteinAddress).getManyProteinStructs(_result.nftIds);
  }

  function queryNftIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputNftIds memory result) {
    return semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
  }

  function querySequences(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputSequences memory result) {
    Structs.QueryOutputNftIds memory _result = semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.sequences = IndexerProtein(indexerProteinAddress).getManyProteinSequences(_result.nftIds);
  }

  function queryIds(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIds memory result) {
    Structs.QueryOutputNftIds memory _result = semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.ids = IndexerProtein(indexerProteinAddress).getManyProteinIds(_result.nftIds);
  }

  function queryIpfsHashes(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  public view returns(Structs.QueryOutputIpfsHashes memory result) {
    Structs.QueryOutputNftIds memory _result = semiBlastAlgorithm(queryInput, queryOptions, indexerProteinAddress);
    
    result.proteinCount = _result.proteinCount;
    result.ipfsHashes = IndexerProtein(indexerProteinAddress).getManyProteinIpfsHashes(_result.nftIds);
  }
  
  function semiBlastAlgorithm(QueryInput memory queryInput, QueryOptions memory queryOptions, address indexerProteinAddress)
  internal view returns(Structs.QueryOutputNftIds memory result) {
    uint wordSize = bytes(queryInput.sequence).length;
    require(wordSize != 0, "Query can't be empty.");
    
    IndexerProtein indexerProtein = IndexerProtein(indexerProteinAddress);
    uint proteinCount = indexerProtein.getProteinCount();
    require(proteinCount > 0, "In order to query in this manner, proteins have to be inserted first.");

    address indexerSeedAddress = indexerProtein.getSeedAddress(queryOptions.seedSize);
    require(indexerSeedAddress != address(0), "Can't query with this seed size.");

    IndexerSeed indexerSeed = IndexerSeed(indexerSeedAddress);
    require(indexerSeed.getSeedCount() > 0, "In order to query in this manner, seeds have to be inserted first.");
    
    if(!queryOptions.caseSensitive) queryInput.sequence = queryInput.sequence.toUpper();

    Structs.QueryOutputPositions memory queryOutputPositions;
    string[] memory splittedQuery;
    uint[] memory pointers;
    uint seedTailSize;

    if(wordSize >= queryOptions.seedSize) {
      // Split the query in short w-sized pieces.
      (splittedQuery, seedTailSize) = queryInput.sequence.fragment(queryOptions.seedSize, queryOptions.seedSize, true);

      // Look where these w-sized pieces could be found in all of our sequences (using a precomputed lookup table, see: CrudSeed.sol or ./datasets/seeds/ on our GitHub.)
      (queryOutputPositions, pointers) = indexerSeed.getQueryPositions(splittedQuery, true);
      (queryOutputPositions.positions, pointers) = sort(queryOutputPositions.positions, pointers);
    } else {
      // Queries shorter than the seedSize are handled differently. We use wildcards to get all matching positions for this query.
      pointers = new uint[](1);
      queryOutputPositions = indexerSeed.getShortQueryPositions(queryInput.sequence, proteinCount, queryOptions.seedSize);
    }

    // returnAll is true if only *'s are found in the query.
    if(queryOutputPositions.returnAll) {
      result = Structs.QueryOutputNftIds(indexerProtein.getProteinIndex(), proteinCount);
      return result;
    }

    // Puzzle the w-sized pieces back together and return only the proteins that successfully match our queried string (in this case the NFT IDs).
    if(!queryOutputPositions.emptyFound) result = puzzleSeedPositions(PuzzleData(queryOutputPositions.positions, pointers, proteinCount, queryOptions.seedSize, queryOptions.seedSize - seedTailSize, queryOptions.limit));
  }
  
  function calculatePositionOffset(uint startPointer, uint currentPointer, PuzzleData memory puzzleData)
  internal pure returns(int positionOffset) {
    int pointerDiff = int(currentPointer) - int(startPointer);
    positionOffset = pointerDiff * int(puzzleData.seedSize) + (startPointer == puzzleData.pointers.length - 1 || currentPointer == puzzleData.pointers.length - 1 
      ? (pointerDiff > 0 ? -1 * int(puzzleData.seedTailOverlap) : int(puzzleData.seedTailOverlap))
      : int(0));
    
    return positionOffset;
  }

  function getValidPositionIndex(PuzzleData memory puzzleData) internal pure returns(uint validIndex) {
    for(uint i = 0; i < puzzleData.positions.length; i++) {
      if(puzzleData.positions[i].length > 0) {
        validIndex = i;
        break;
      }
    }
  }

  // Puzzling the puzzle pieces together. This is the final step of the "SEMI-BLAST" algorithm.
  function puzzleSeedPositions(PuzzleData memory puzzleData)
  internal pure returns(Structs.QueryOutputNftIds memory result) {
    uint firstValidPosition = getValidPositionIndex(puzzleData);
    uint maxQueryAmount = puzzleData.positions[firstValidPosition].length;

    uint[] memory _nftIds = new uint[](maxQueryAmount);
    Structs.SeedPositionStruct[] memory possibleMatches = new Structs.SeedPositionStruct[](maxQueryAmount);
    
    possibleMatches = puzzleData.positions[firstValidPosition];

    int[] memory mismatchCounter = new int[](maxQueryAmount);
    bool[] memory addedProteins = new bool[](puzzleData.proteinCount);

    for (uint i = 0; i < maxQueryAmount; i++) {
      // If the protein doesn't exist or has already been added, it's not necessary to include it in our calculations.
      if(possibleMatches[i].nftId > addedProteins.length || addedProteins[possibleMatches[i].nftId - 1]) continue; 

      // If there's only one 3 letter word and the rest were ***'s
      if(firstValidPosition != 0 && firstValidPosition == puzzleData.positions.length - 1) {
        // 
        if(possibleMatches[i].position < (puzzleData.seedSize - puzzleData.seedTailOverlap)) {
          continue;
        }
      }

      for(uint j = firstValidPosition + 1; j < puzzleData.positions.length; j++) {
        
        //empty arrays are "***"-wildcards (depending on the seedSize, in this case I give an example where seedSize = 3).
        if(puzzleData.positions[j].length == 0) continue;

        for(uint k = 0; k < puzzleData.positions[j].length; k++) {
          Structs.SeedPositionStruct memory currentSeedPosition = puzzleData.positions[j][k];

          // Again, if the protein doesn't exist or was already added, skip.
          if(currentSeedPosition.nftId > addedProteins.length || addedProteins[currentSeedPosition.nftId - 1]) {
            // Also, treat this round as a mismatch.
            mismatchCounter[i]++;   
            continue;
          }
          
          int nextPosition = int(possibleMatches[i].position) + calculatePositionOffset(puzzleData.pointers[firstValidPosition], puzzleData.pointers[j], puzzleData);


          // The current position can't possibly be lower than what's the next minimum expected position, else the sequence would have a starting position of below 0.
          if(currentSeedPosition.position < ((puzzleData.pointers[j] * puzzleData.seedSize) - 
          (puzzleData.pointers[j] != 0 && (puzzleData.pointers[firstValidPosition] == puzzleData.pointers.length - 1 || puzzleData.pointers[j] == puzzleData.pointers.length - 1) 
          ? puzzleData.seedTailOverlap : 0))) {
            mismatchCounter[i]++;   
            continue;
          }

          // if nftId's match AND (previous position + seedSize) equals the current position, then we have a match.
          // However, there's an exception to this rule at the last seed, for this word may overlap with the second last word.
          // See fragment() in the Strings.sol library for more information. Particularly the 'forceSize' parameter.
          if(possibleMatches[i].nftId == currentSeedPosition.nftId && 
          int(currentSeedPosition.position) == nextPosition) {
            // possibleMatches[i].position = puzzleData.positions[j][k].position;
            mismatchCounter[i] = -1;
            break;
          } else {
            mismatchCounter[i]++;
          }
        }

        // -1 means we found a match, anything higher indicates that we've only encountered mismatches
        if(mismatchCounter[i] > 0) break; 
        
        // Reset the counter (only happens if this round matched)
        mismatchCounter[i] = 0;
      }

      if(mismatchCounter[i] > 0) continue;

      // If we made it this far, it means a match was found
      _nftIds[result.proteinCount] = possibleMatches[i].nftId;
      result.proteinCount++;
      addedProteins[possibleMatches[i].nftId - 1] = true;

      // Stop looking for more if we found enough matching proteins.
      if(result.proteinCount == puzzleData.limit) break;
    }

    // Shrink the size of the resulting array
    result.nftIds = new uint[](result.proteinCount);
    for(uint i = 0; i < result.proteinCount; i++) result.nftIds[i] = _nftIds[i];
  }


  // Basis from Subhodi: https://gist.github.com/subhodi/b3b86cc13ad2636420963e692a4d896f
  // Altered for our needs.
  function sort(Structs.SeedPositionStruct[][] memory positions, uint[] memory pointers)
  public pure returns(Structs.SeedPositionStruct[][] memory, uint[] memory) {
       quickSort(positions, pointers, int(0), int(positions.length - 1));
       return (positions, pointers);
    }
    
    function quickSort(Structs.SeedPositionStruct[][] memory positions, uint[] memory pointers, int left, int right) internal pure {
        int i = left;
        int j = right;
        if(i==j) return;
        uint pivot = positions[uint(left + (right - left) / 2)].length;
        while (i <= j) {
            while (positions[uint(i)].length < pivot) i++;
            while (pivot < positions[uint(j)].length) j--;
            if (i <= j) {
                (positions[uint(i)], positions[uint(j)]) = (positions[uint(j)], positions[uint(i)]);
                (pointers[uint(i)], pointers[uint(j)]) = (pointers[uint(j)], pointers[uint(i)]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(positions, pointers, left, j);
        if (i < right)
            quickSort(positions, pointers, i, right);
    }
}
