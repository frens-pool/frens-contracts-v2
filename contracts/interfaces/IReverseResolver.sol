// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IReverseResolver{

    function name(bytes32 node) external view returns(string memory);

}