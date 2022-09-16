pragma solidity ^0.8.12;
import '../base/Owner.sol';
import '../../libraries/Structs.sol';

//SPDX-License-Identifier: UNLICENSED
//Created by Tousuke (zenodeapp - https://github.com/zenodeapp/protein-crud).

//Basis from Rob Hitchens's UserCrud, found on: https://bitbucket.org/rhitchens2/soliditycrud/src/master/
//Updated to solidity ^0.8.0 and edited/extended for protein strings by Tousuke.

contract CrudProtein is Owner {
  uint[] public proteinIndex;
  mapping(uint => Structs.ProteinStruct) public proteinStructs;

  uint public nftIdCeil;

  event LogNewProtein (uint indexed nftId, uint index, string id, string sequence, string ipfsHash, string fastaMetadata);
  event LogUpdateProtein (uint indexed nftId, uint index, string id, string sequence, string ipfsHash, string fastaMetadata);
  event LogDeleteProtein (uint indexed nftId, uint index);

  function insertProtein(uint nftId, string memory id,
  string memory sequence, string memory ipfsHash, string memory fastaMetadata, bool bypassRevert) public onlyAdmin returns(uint index) {
    bool exists = isProtein(nftId);

    if(bypassRevert && exists) {
      return proteinIndex.length - 1;
    } else {
      require(!exists, "This nft already exists and can't be inserted twice. Update its properties instead.");
    }
    
    proteinStructs[nftId].nftId = nftId;
    proteinStructs[nftId].id = id;
    proteinStructs[nftId].sequence = sequence;
    proteinStructs[nftId].ipfsHash = ipfsHash;
    proteinStructs[nftId].fastaMetadata = fastaMetadata;
    
    proteinIndex.push(nftId);
    proteinStructs[nftId].index = proteinIndex.length - 1;
    if(nftIdCeil < nftId) nftIdCeil = nftId;

    emit LogNewProtein(nftId, proteinStructs[nftId].index, id, sequence, ipfsHash, fastaMetadata);

    return proteinIndex.length - 1;
  }

  function insertManyProteins(uint[] memory nftIds, string[] memory ids, 
  string[] memory sequences, string[] memory ipfsHashes, string[] memory fastaMetadata, bool bypassRevert) public onlyAdmin returns(uint index) {
    for(uint i = 0; i < nftIds.length; i++) {
      insertProtein(nftIds[i], ids[i], sequences[i], ipfsHashes[i], fastaMetadata[i], bypassRevert);
    }

    return proteinIndex.length - 1;
  }

  function updateProtein(uint nftId, string memory id, string memory sequence,
  string memory ipfsHash, string memory fastaMetadata, bool bypassRevert) public onlyAdmin returns(bool success) {
    bool exists = isProtein(nftId);

    if(bypassRevert && !exists) {
      return true;
    } else {
      require(exists, "NFT ID could not be found in the database.");
    }
    
    proteinStructs[nftId].nftId = nftId;
    proteinStructs[nftId].id = id;
    proteinStructs[nftId].sequence = sequence;
    proteinStructs[nftId].ipfsHash = ipfsHash;
    proteinStructs[nftId].fastaMetadata = fastaMetadata;

    emit LogUpdateProtein(nftId, proteinStructs[nftId].index, id, sequence, ipfsHash, fastaMetadata);

    return true;
  }

  function updateManyProteins(uint[] memory nftIds, string[] memory ids, 
  string[] memory sequences, string[] memory ipfsHashes, string[] memory fastaMetadata, bool bypassRevert) public onlyAdmin returns(bool success) {
    for(uint i = 0; i < nftIds.length; i++) {
      updateProtein(nftIds[i], ids[i], sequences[i], ipfsHashes[i], fastaMetadata[i], bypassRevert);
    }

    return true;
  }

  // Hard deletion will also reset all values inserted in the protein structs. This is costly and not necessary.
  function deleteProtein(uint nftId, bool hardDelete, bool bypassRevert) public onlyAdmin returns(uint proteinsLeft) {
    if(hardDelete) {
      proteinStructs[nftId].nftId = 0;
      proteinStructs[nftId].sequence = "";
      proteinStructs[nftId].id = "";
      proteinStructs[nftId].ipfsHash = "";
      proteinStructs[nftId].fastaMetadata = "";
    }

    bool exists = isProtein(nftId);

    if(bypassRevert && !exists) {
      return 0;
    } else {
      require(exists, "NFT ID could not be found in the database."); 
    }

    uint rowToDelete = proteinStructs[nftId].index;
    uint keyToMove = proteinIndex[proteinIndex.length - 1];

    proteinIndex[rowToDelete] = keyToMove;
    proteinStructs[keyToMove].index = rowToDelete; 
    proteinStructs[nftId].index = 0;
    proteinIndex.pop();

    emit LogDeleteProtein(nftId, rowToDelete);
    
    Structs.ProteinStruct memory _proteinStruct = proteinStructs[keyToMove];
    emit LogUpdateProtein(keyToMove, rowToDelete, _proteinStruct.id, _proteinStruct.sequence, _proteinStruct.ipfsHash, _proteinStruct.fastaMetadata);

    return proteinIndex.length;
  }

  function deleteManyProteins(uint[] memory nftIds, bool hardDelete, bool bypassRevert) public onlyAdmin returns(uint proteinsLeft) {
    for(uint i = 0; i < nftIds.length; i++) {
      deleteProtein(nftIds[i], hardDelete, bypassRevert);
    }

    return proteinIndex.length;
  }

  // May result in an out-of-gas error if the protein size is too big (use deleteManyProteins instead if this happens).
  function deleteAllProteins(bool hardDelete) public onlyAdmin returns(uint proteinsLeft) {
    uint _proteinLength = proteinIndex.length;

    for(uint i = 0; i < _proteinLength; i++) {
      deleteProtein(proteinIndex[0], hardDelete, false);
    }
    
    nftIdCeil = 0;
    return proteinIndex.length;
  }

  function undoProteinDeletion(uint nftId) public onlyAdmin returns(uint index) {
    require(!isProtein(nftId) && nftId == proteinStructs[nftId].nftId, "Reverting soft-deletions can only be done on proteins that have been soft-deleted.");

    proteinIndex.push(nftId);
    proteinStructs[nftId].index = proteinIndex.length - 1;
    
    if(nftIdCeil < nftId) nftIdCeil = nftId;

    Structs.ProteinStruct memory _proteinStruct = proteinStructs[nftId];
    emit LogNewProtein(nftId, _proteinStruct.index, _proteinStruct.id, _proteinStruct.sequence, _proteinStruct.ipfsHash, _proteinStruct.fastaMetadata);

    return proteinIndex.length - 1;
  }

  function isProtein(uint nftId) public view returns(bool isIndeed) {
    if(proteinIndex.length == 0) return false;

    return (proteinIndex[proteinStructs[nftId].index] == nftId);
  }

  function getProtein(uint _nftId) public view returns(uint nftId, string memory id, string memory sequence, string memory ipfsHash, string memory fastaMetadata, uint index) {
    require(isProtein(_nftId), "NFT ID could not be found in the database."); 

    Structs.ProteinStruct memory _proteinStruct = proteinStructs[_nftId];
    return(
      _proteinStruct.nftId, 
      _proteinStruct.id, 
      _proteinStruct.sequence,
      _proteinStruct.ipfsHash,
      _proteinStruct.fastaMetadata,
      _proteinStruct.index);
  }

  function getProteinStruct(uint nftId) public view returns(Structs.ProteinStruct memory proteinStruct) {
    return proteinStructs[nftId];
  }

  function getProteinStructAtIndex(uint index) public view returns(Structs.ProteinStruct memory proteinStruct) {
    return proteinStructs[proteinIndex[index]];
  }

  function getManyProteinStructs(uint[] memory nftIds) public view returns(Structs.ProteinStruct[] memory proteins) {
    proteins = new Structs.ProteinStruct[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      proteins[i] = getProteinStruct(nftIds[i]);
    }
  }

  function getManyProteinStructsAtIndices(uint[] memory indices) public view returns(Structs.ProteinStruct[] memory proteins) {
    proteins = new Structs.ProteinStruct[](indices.length);

    for(uint i = 0; i < indices.length; i++) {
      proteins[i] = getProteinStructAtIndex(indices[i]);
    }
  }

  function getAllProteinStructs() public view returns(Structs.ProteinStruct[] memory _proteinStructs) {
    _proteinStructs = new Structs.ProteinStruct[](proteinIndex.length);

    for(uint i = 0; i < proteinIndex.length; i++) {
      _proteinStructs[i] = getProteinStruct(proteinIndex[i]);
    }
  }

  function getManyProteinNftIdsAtIndices(uint[] memory indices) public view returns(uint[] memory nftIds) {
    nftIds = new uint[](indices.length);

    for(uint i = 0; i < indices.length; i++) {
      nftIds[i] = getProteinStructAtIndex(indices[i]).nftId;
    }
  }

  function getManyProteinIds(uint[] memory nftIds) public view returns(string[] memory ids) {
    ids = new string[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      ids[i] = getProteinStruct(nftIds[i]).id;
    }
  }

  function getManyProteinIdsAtIndices(uint[] memory indices) public view returns(string[] memory ids) {
    ids = new string[](indices.length);

    for(uint i = 0; i < indices.length; i++) {
      ids[i] = getProteinStructAtIndex(indices[i]).id;
    }
  }

  function getManyProteinSequences(uint[] memory nftIds) public view returns(string[] memory sequences) {
    sequences = new string[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      sequences[i] = getProteinStruct(nftIds[i]).sequence;
    }
  }

  function getManyProteinSequencesAtIndices(uint[] memory indices) public view returns(string[] memory sequences) {
    sequences = new string[](indices.length);

    for(uint i = 0; i < indices.length; i++) {
      sequences[i] = getProteinStructAtIndex(indices[i]).sequence;
    }
  }

  function getManyProteinIpfsHashes(uint[] memory nftIds) public view returns(string[] memory ipfsHashes) {
    ipfsHashes = new string[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      ipfsHashes[i] = getProteinStruct(nftIds[i]).ipfsHash;
    }
  }

  function getManyProteinIpfsHashesAtIndices(uint[] memory indices) public view returns(string[] memory ipfsHashes) {
    ipfsHashes = new string[](indices.length);

    for(uint i = 0; i < indices.length; i++) {
      ipfsHashes[i] = getProteinStructAtIndex(indices[i]).ipfsHash;
    }
  }

  function getManyProteinFastaMetadata(uint[] memory nftIds) public view returns(string[] memory fastaMetadata) {
    fastaMetadata = new string[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      fastaMetadata[i] = getProteinStruct(nftIds[i]).fastaMetadata;
    }
  }

  function getManyProteinFastaMetadataAtIndices(uint[] memory indices) public view returns(string[] memory fastaMetadata) {
    fastaMetadata = new string[](indices.length);

    for(uint i = 0; i < indices.length; i++) {
      fastaMetadata[i] = getProteinStructAtIndex(indices[i]).fastaMetadata;
    }
  }

  function getManyProteinFastaSequences(uint[] memory nftIds) public view returns(string[] memory fastaSequences) {
    fastaSequences = new string[](nftIds.length);

    for(uint i = 0; i < nftIds.length; i++) {
      Structs.ProteinStruct memory _proteinStruct = getProteinStruct(nftIds[i]);
      fastaSequences[i] = bytes(_proteinStruct.fastaMetadata).length > 0 
        ? string.concat(_proteinStruct.fastaMetadata, "\n", _proteinStruct.sequence) 
        : _proteinStruct.sequence;
    }
  }

  function getManyProteinFastaSequencesAtIndices(uint[] memory indices) public view returns(string[] memory fastaSequences) {
    fastaSequences = new string[](indices.length);

    for(uint i = 0; i < indices.length; i++) {
      Structs.ProteinStruct memory _proteinStruct = getProteinStructAtIndex(indices[i]);
      fastaSequences[i] = bytes(_proteinStruct.fastaMetadata).length > 0 
        ? string.concat(_proteinStruct.fastaMetadata, "\n", _proteinStruct.sequence) 
        : _proteinStruct.sequence;
    }
  }

  function getProteinCount() public view returns(uint count) {
    return proteinIndex.length;
  }

  function getProteinIndex() public view returns(uint[] memory nftIds) {
    return proteinIndex;
  }

  function getProteinAtIndex(uint index) public view returns(uint nftId) {
    return proteinIndex[index];
  }
}