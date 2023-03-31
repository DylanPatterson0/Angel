//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ITokenTemplate is IERC20 {
    /**
     * @dev Bids on an auction using external funds, emits event Bid
     * Must check if auction exists && auction hasn't ended && bid isn't too low
     */
    function setControllerContract(address _controllerContract) external;

    function getControllerContract() external;

    function transfer() external;

    function transferFrom() external;
}

contract TokenTemplate is ERC20 {

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC20(_name, _symbol) {}

    function setControllerContract(address _controllerContract) external {}

    function getControllerContract() external {}

    function transfer() external {}

    function transferFrom() external {}
}