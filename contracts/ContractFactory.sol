//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ControllerTemplate.sol";
import "./TokenTemplate.sol";

interface IContractFactory {
    event TokenDeployed(
        address operator,
        string name,
        string symbol,
        uint256 maxSupply,
        uint256 marketCap
    );
    event ControllerDeployed(address operator);

    function launchTokenControllerPair(
        address operator,
        string calldata name,
        string calldata symbol,
        uint256 maxSupply,
        uint256 marketCap
    ) external returns (TokenTemplate, ControllerTemplate);
}

contract ContractFactory is IContractFactory, Ownable, Pausable {
    TokenTemplate private _token;
    ControllerTemplate private _controller;
    TokenTemplate[] private _tokenList;
    ControllerTemplate[] private _controllerList;
    // update this whenever setTokenContract is called
    mapping(ControllerTemplate => TokenTemplate)
        private _controllerToTokenTracker;

    function createToken(
        address operator,
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 marketCap
    ) public onlyOwner {
        _token = new TokenTemplate(name, symbol, maxSupply, marketCap);
        _tokenList.push(_token);
        emit TokenDeployed(operator, name, symbol, maxSupply, marketCap);
    }

    function createController(
        address operator,
        uint256 maxSupply,
        uint256 marketCap
    ) public onlyOwner {
        _controller = new ControllerTemplate(operator, maxSupply, marketCap);
        _controllerList.push(_controller);
        emit ControllerDeployed(operator);
    }

    function launchTokenControllerPair(
        address operator,
        string calldata name,
        string calldata symbol,
        uint256 maxSupply,
        uint256 marketCap
    ) public override onlyOwner returns (TokenTemplate, ControllerTemplate) {
        createController(operator, maxSupply, marketCap);
        createToken(operator, name, symbol, maxSupply, marketCap);
        _controller.setTokenContract(address(_token));
        _token.setControllerContract(address(_controller));
        return (_token, _controller);
    }
}
