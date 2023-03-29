//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IContractFactory {
    event TokenDeployed();
    event ControllerDeployed();

    function CreateToken() external;

    function CreateController(address _owner) external;
}