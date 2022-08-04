pragma solidity ^0.8.12;

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

contract QueryHelpers {
  // Splits a string into smaller segments based on the given size and step-size. Here follow some examples:
  // word=ABCDEF, size=3 and step=1 will give every possible 3 letter segment in the word: [ABC, BCD, CDE, DEF].
  // word=ABCDEF, size=4 and step=2 will result in: [ABCD, CDEF, EF].
  // word=ABCDEFG, size=3 and step=3 will give every segment without overlap: [ABC, DEF, G].
  // word=ABCDEFG, size=3, step=3 and forceSize=true will result in: [ABC, DEF, EFG].
  function splitWord(string memory word, uint size, uint step, bool forceSize) internal pure returns(string[] memory segments, uint seedTailSize) {
    require(step <= size, "Step can't be higher than the given size.");
    require(step > 0, "A step value higher than 0 is required.");

    bytes memory wordBytes = bytes(word);
    uint wordSize = wordBytes.length;

    require(wordSize >= size, "Word can't be smaller than the segment size.");

    uint wordPointer = 0;
    uint wordThreshold = wordSize - size;
    uint wordCount = (wordThreshold / step) + (wordThreshold % step > 0 ? 1 : 0) + 1;

    segments = new string[](wordCount);

    for(uint i = 0; i < wordCount; i++) {
      bytes memory segment = i < wordCount - 1
        ? sliceBytes(wordBytes, wordPointer, size)
        : forceSize
          ? sliceBytes(wordBytes, wordSize - size, size)
          : sliceBytes(wordBytes, wordPointer, wordSize - wordPointer);

      segments[i] = string(segment);
      
      wordPointer = i == wordCount - 1
        ? wordPointer
        : wordPointer + step;
    }


    // A word can't always be split equally in w-sized pieces,
    // This integer indicates how many characters the last word returned.
    // NOTE: even if forceSize is turned on, this will still return the tail size as if forceSize was turned off.
    seedTailSize = wordSize - wordPointer;
  }

  function sliceBytes(bytes memory word, uint start, uint size) internal pure returns(bytes memory sliced) {
    require(start + size <= word.length,  "Sliced segment is outside the scope of the byte array.");

    sliced = new bytes(size);
    for (uint j = 0; j < size; j++) { 
      sliced[j] = word[start + j]; 
    }
  }

  // https://ethereum.stackexchange.com/questions/30912/how-to-compare-strings-in-solidity
  function compareStrings(string memory a, string memory b) internal pure returns (bool) {
    return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
  }

  // From Hermes Ateneo (https://github.com/HermesAteneo/solidity-repeated-word-in-string/blob/main/RepeatedWords.sol)
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
