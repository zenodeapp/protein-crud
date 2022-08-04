pragma solidity ^0.8.12;
import './Owner.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

//Basis from Rob Hitchens's UserCrud, found on: https://bitbucket.org/rhitchens2/soliditycrud/src/master/
//Updated to solidity ^0.8.0 and edited/extended for protein strings by Tousuke.
contract ProteinCrud is Owner {
  struct ProteinStruct {
    string id;
    string sequence;
    uint index;
  }

  uint[] internal proteinIndex;
  mapping(uint => ProteinStruct) internal proteinStructs;

  event LogNewProtein (uint indexed nftId, uint index, string id, string sequence);
  event LogUpdateProtein (uint indexed nftId, uint index, string id, string sequence);
  event LogDeleteProtein (uint indexed nftId, uint index);

  function insertProtein(uint nftId, string memory id,
  string memory sequence, bool bypassRevert) public onlyAdmin returns(uint index) {
    bool exists = isProtein(nftId);

    if(bypassRevert && exists) {
      return proteinIndex.length - 1;
    } else {
      require(!exists, "This nft already exists and can't be inserted twice. Update its properties instead.");
    }

    proteinStructs[nftId].id = id;
    proteinStructs[nftId].sequence = sequence;
    
    proteinIndex.push(nftId);
    proteinStructs[nftId].index = proteinIndex.length - 1;

    emit LogNewProtein(nftId, proteinStructs[nftId].index, id, sequence);

    return proteinIndex.length-1;
  }

  function insertProteins(uint[] memory nftIds, string[] memory ids, 
  string[] memory sequences, bool bypassRevert) public onlyAdmin returns(uint index) {
    for(uint i = 0; i < nftIds.length; i++) {
      insertProtein(nftIds[i], ids[i], sequences[i], bypassRevert);
    }

    return proteinIndex.length - 1;
  }

  function updateProteinId(uint nftId, string memory id) public onlyAdmin returns(bool success) {
    require(isProtein(nftId), "NFT ID could not be found in the database."); 

    proteinStructs[nftId].id = id;

    ProteinStruct memory _proteinStruct = proteinStructs[nftId];
    emit LogUpdateProtein(nftId, _proteinStruct.index, id, _proteinStruct.sequence);

    return true;
  }

  function updateProteinSequence(uint nftId, string memory sequence) public onlyAdmin returns(bool success) {
    require(isProtein(nftId), "NFT ID could not be found in the database."); 

    proteinStructs[nftId].sequence = sequence;

    ProteinStruct memory _proteinStruct = proteinStructs[nftId];
    emit LogUpdateProtein(nftId, _proteinStruct.index, _proteinStruct.id, sequence);

    return true;
  }

  function deleteProtein(uint nftId) public onlyAdmin returns(uint index) {
    require(isProtein(nftId), "NFT ID could not be found in the database."); 

    uint rowToDelete = proteinStructs[nftId].index;
    uint keyToMove = proteinIndex[proteinIndex.length - 1];

    proteinIndex[rowToDelete] = keyToMove;
    proteinStructs[keyToMove].index = rowToDelete; 
    proteinIndex.pop();

    emit LogDeleteProtein(nftId, rowToDelete);
    
    ProteinStruct memory _proteinStruct = proteinStructs[keyToMove];
    emit LogUpdateProtein(keyToMove, rowToDelete, _proteinStruct.id, _proteinStruct.sequence);

    return rowToDelete;
  }

  function getProtein(uint nftId) public view returns(string memory id, string memory sequence, uint index) {
    require(isProtein(nftId), "NFT ID could not be found in the database."); 

    ProteinStruct memory _proteinStruct = proteinStructs[nftId];
    return(
      _proteinStruct.id, 
      _proteinStruct.sequence, 
      _proteinStruct.index);
  }

  function isProtein(uint nftId) public view returns(bool isIndeed) {
    if(proteinIndex.length == 0) return false;

    return (proteinIndex[proteinStructs[nftId].index] == nftId);
  }

  function proteinCount() public view returns(uint count) {
    return proteinIndex.length;
  }

  function proteinAtIndex(uint index) public view returns(uint nftId) {
    return proteinIndex[index];
  }
}