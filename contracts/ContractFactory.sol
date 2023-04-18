//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ControllerTemplate.sol";
import "./TokenTemplate.sol";

interface IContractFactory {
    event TokenDeployed();
    event ControllerDeployed();

    function createToken(
        string calldata _name,
        string calldata _symbol,
        uint256 _maxSuppl
    ) external;

    function createController(address _owner) external;
}

contract ContractFactory is IContractFactory {
    TokenTemplate private _token;

    ControllerTemplate private _controller;

    TokenTemplate[] private _tokenList;

    ControllerTemplate[] private _controllerList;

    // update this whenever setTokenContract is called
    mapping(ControllerTemplate => TokenTemplate)
        private _controllerToTokenTracker;

    function createToken(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply
    ) external override {
        _token = new TokenTemplate(_name, _symbol, _maxSupply);

        _tokenList.push(_token);
    }

    function createController(address _owner) external override {
        _controller = new ControllerTemplate(_owner);

        _controllerList.push(_controller);
    }
}
