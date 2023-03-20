pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT


interface IFrensMerkleProver{

    function verify(bytes32[] calldata merkleProof, bytes32 merkleRoot, address sender) external;
    
}