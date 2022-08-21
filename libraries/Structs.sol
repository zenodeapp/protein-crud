pragma solidity ^0.8.12;

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

library Structs {
  struct ProteinStruct {
    uint nftId;
    string id;
    string sequence;
    string ipfsHash;
    uint index;
  }

  struct SeedStruct {
    string seed;
    SeedPositionStruct[] positions;
    uint index;
  }

  struct SeedPositionStruct {
    uint nftId;
    uint position;
  }

  struct WildcardStruct {
    string wildcard;
    string[] seeds;
    uint count;
    uint index;
  }

  // For instance an indexer group: 'Homo Sapiens', with an ID of 2 would be the second Indexer for this protein type.
  struct IndexerStruct {
    string group;
    uint id;
  }

  struct QueryOutputNftIds {
    uint[] nftIds;
    uint proteinCount;
  }

  struct QueryOutputSequences {
    string[] sequences;
    uint proteinCount;
  }

  struct QueryOutputIds {
    string[] ids;
    uint proteinCount;
  }

  struct QueryOutputIpfsHashes {
    string[] ipfsHashes;
    uint proteinCount;
  }

  struct QueryOutputProteinStructs {
    ProteinStruct[] proteins;
    uint proteinCount;
  }

  struct QueryOutputPositions {
    SeedPositionStruct[][] positions;
    bool emptyFound;
    bool returnAll;
  }
}