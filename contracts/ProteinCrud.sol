pragma solidity ^0.8.9;

import './Owner.sol';

//SPDX-License-Identifier: UNLICENSED
//Basis from Rob Hitchens's UserCrud, found on: https://bitbucket.org/rhitchens2/soliditycrud/src/master/
//Updated to the latest version of Solidity and edited for protein strings by Tousuke (anodeofzen/zenode.app).
contract ProteinCrud is Owner {
  struct ProteinStruct {
    string id;
    string sequence;
    uint index;
  }
  
  mapping(uint => ProteinStruct) internal proteinStructs;
  uint[] internal proteinIndex;

  event LogNewProtein (uint indexed nftId, uint index, string id, string sequence);
  event LogUpdateProtein (uint indexed nftId, uint index, string id, string sequence);
  event LogDeleteProtein (uint indexed nftId, uint index);

  function isProtein(uint nftId) public view returns(bool isIndeed) {
    if(proteinIndex.length == 0) return false;

    return (proteinIndex[proteinStructs[nftId].index] == nftId);
  }

  function insertProteins(uint[] memory nftIds, string[] memory ids, string[] memory sequences, bool bypassRevert) public onlyOwner returns(uint index) {
    for(uint i = 0; i < nftIds.length; i++) {
      insertProtein(nftIds[i], ids[i], sequences[i], bypassRevert);
    }

    return proteinIndex.length-1;
  }

  function insertProtein(uint nftId, string memory id, string memory sequence, bool bypassRevert) public onlyOwner returns(uint index) {
    bool exists = isProtein(nftId);

    if(bypassRevert && exists) {
      return proteinIndex.length-1;
    } else {
      require(!exists, "This nft already exists and can't be inserted twice. Update its properties instead.");
    }

    proteinStructs[nftId].id = id;
    proteinStructs[nftId].sequence = sequence;
    proteinIndex.push(nftId);
    proteinStructs[nftId].index = proteinIndex.length - 1;

    emit LogNewProtein(
        nftId, 
        proteinStructs[nftId].index, 
        id, 
        sequence);

    return proteinIndex.length-1;
  }

  function deleteProtein(uint nftId) public onlyOwner returns(uint index) {
    require(isProtein(nftId), "NFT ID could not be found in the database."); 
    
    uint rowToDelete = proteinStructs[nftId].index;
    uint keyToMove = proteinIndex[proteinIndex.length-1];
    proteinIndex[rowToDelete] = keyToMove;
    proteinStructs[keyToMove].index = rowToDelete; 
    proteinIndex.pop();

    emit LogDeleteProtein(
        nftId, 
        rowToDelete);

    emit LogUpdateProtein(
        keyToMove, 
        rowToDelete, 
        proteinStructs[keyToMove].id, 
        proteinStructs[keyToMove].sequence);
    return rowToDelete;
  }
  
  function getProtein(uint nftId) public view returns(string memory id, string memory sequence, uint index) {
    require(isProtein(nftId), "NFT ID could not be found in the database."); 
    
    return(
      proteinStructs[nftId].id, 
      proteinStructs[nftId].sequence, 
      proteinStructs[nftId].index);
  } 
  
  function updateProteinId(uint nftId, string memory id) public onlyOwner returns(bool success) {
    require(isProtein(nftId), "NFT ID could not be found in the database."); 
    
    proteinStructs[nftId].id = id;
    
    emit LogUpdateProtein(
      nftId, 
      proteinStructs[nftId].index,
      id, 
      proteinStructs[nftId].sequence);
    return true;
  }
  
  function updateProteinSequence(uint nftId, string memory sequence) public onlyOwner returns(bool success) {
    require(isProtein(nftId), "NFT ID could not be found in the database."); 
    
    proteinStructs[nftId].sequence = sequence;
   
    emit LogUpdateProtein(
      nftId, 
      proteinStructs[nftId].index,
      proteinStructs[nftId].id, 
      sequence);
    return true;
  }

  function getProteinCount() public view returns(uint count) {
    return proteinIndex.length;
  }

  function getProteinAtIndex(uint index) public view returns(uint nftId) {
    return proteinIndex[index];
  }
}