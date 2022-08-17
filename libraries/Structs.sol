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

  struct IndexerStruct {
    string group;
    uint id;
  }

  struct QueryResultNftIds {
    uint[] nftIds;
    uint proteinCount;
  }

  struct QueryResultSequences {
    string[] sequences;
    uint proteinCount;
  }

  struct QueryResultIds {
    string[] ids;
    uint proteinCount;
  }

  struct QueryResultIpfsHashes {
    string[] ipfsHashes;
    uint proteinCount;
  }

  struct QueryResultProteinStructs {
    Structs.ProteinStruct[] proteins;
    uint proteinCount;
  }

  //This function allows us to resize ProteinStruct arrays to appropriate lengths by copying data to a new sized array.
  function resizeArray(ProteinStruct[] memory _from, ProteinStruct[] memory _to, uint _size) public pure returns(ProteinStruct[] memory) {
    _to = new ProteinStruct[](_size);

    for(uint i = 0; i < _size; i++) {
      _to[i] = _from[i];
    }

    return _to;
  }
}