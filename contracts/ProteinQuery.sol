pragma solidity ^0.8.9;
//SPDX-License-Identifier: UNLICENSED

import './ProteinCrud.sol';

contract ProteinQuery is ProteinCrud {
  // Query proteins by ID and/or Sequence. The returned value equals all proteins and the amount that has been found.
  function queryProtein(string memory idQuery, string memory sequenceQuery, bool exclusive) public view returns(ProteinStruct[] memory proteins, uint proteinsFound) {
      //We'll have to temporarily create an array with a length equal to all proteins stored in our database.
      ProteinStruct[] memory _proteins = new ProteinStruct[](proteinIndex.length);
      ProteinStruct memory _protein;

      bool idIsEmpty = bytes(idQuery).length == 0;
      bool sequenceIsEmpty = bytes(sequenceQuery).length == 0;

      for(uint i = 0; i < proteinIndex.length; i++) {
        _protein = proteinStructs[proteinIndex[i]];
        bool includeId = !idIsEmpty && containsWord(idQuery, _protein.id);
        bool includeSequence = !sequenceIsEmpty && containsWord(sequenceQuery, _protein.sequence);
      
        bool condition = !exclusive
            ? includeId || includeSequence
            : includeId && includeSequence;

        if(condition) {
            _proteins[proteinsFound] = _protein;
            proteinsFound++;
        }
      }

    // The problem with Solidity is that memory array's have a fixed size. So we can't work with dynamic arrays (unless we use storage, but this costs gas).
    // So after we discover how many proteins were found, we resize the returned array to the appropriate size.
    proteins = resizeProteinStructArray(_proteins, proteins, proteinsFound);

    // The resizing is an extra step and impacts our query's performance, therefore, use the commented out section instead, if you'd like to speed things up.
    // Just know that you'll have to process the result in the front-end accordingly (filtering out all empty indices).
    // proteins = _proteins;
  }

  //This function allows us to resize ProteinStruct arrays to appropriate lengths by copying data to a new sized array.
  function resizeProteinStructArray(ProteinStruct[] memory _from, ProteinStruct[] memory _to, uint _size) private pure returns(ProteinStruct[] memory) {
    _to = new ProteinStruct[](_size);

    for(uint i = 0; i < _size; i++) {
      _to[i] = _from[i];
    }

    return _to;
  }

  // Credit: Hermes Ateneo (https://github.com/HermesAteneo/solidity-repeated-word-in-string/blob/main/RepeatedWords.sol)
  function containsWord(string memory what, string memory where) internal pure returns (bool found) {
    bytes memory whatBytes = bytes(what);
    bytes memory whereBytes = bytes(where);

    if (whereBytes.length < whatBytes.length) return false;

    found = false;
    for (uint i = 0; i <= whereBytes.length - whatBytes.length; i++) {
      bool flag = true;

      for (uint j = 0; j < whatBytes.length; j++) {
        if (whereBytes [i + j] != whatBytes [j]) {
          flag = false;
          break;
        }
      }
      
      if (flag) {
        found = true;
        break;
      }
    }

    return found;
  }
}
