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

    function launchTokenControllerPair(address operator, string calldata name, string calldata symbol, uint256 maxSupply) external;
}

contract ContractFactory is IContractFactory, Ownable, Pausable {

    TokenTemplate private _token;

    ControllerTemplate private _controller;

    TokenTemplate[] private _tokenList;

    ControllerTemplate[] private _controllerList;

    // update this whenever setTokenContract is called
    mapping(ControllerTemplate => TokenTemplate) private _controllerToTokenTracker; 
    

    function createToken(string memory _name, string memory _symbol, uint256 _maxSupply) public {
        _token = new TokenTemplate(_name, _symbol, _maxSupply);

        _tokenList.push(_token);


    }

    function createController(address operator) public onlyOwner{
        _controller = new ControllerTemplate(operator);

        _controllerList.push(_controller);
    }

    function launchTokenControllerPair(address operator, string calldata name, string calldata symbol, uint256 maxSupply) public onlyOwner{
        createController(operator);
        createToken(name, symbol, maxSupply);

        _controller.setTokenContract(address(_token));
        _token.setControllerContract(address(_controller));

    }

}