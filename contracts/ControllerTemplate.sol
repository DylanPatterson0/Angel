//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TokenTemplate.sol";

interface IControllerTemplate {
    event Invested(uint256 _amount, address _investor, address _company);
    event Sold(uint256 amount, address _company, address _buyer, address _seller);

    function setTokenContract(address tokenContract) external;

    function invest(uint256 _amount, address _company) external;

    function sellTokens(uint256 _amount, address _company) external;

}

contract ControllerTemplate is IControllerTemplate {

    TokenTemplate internal _tokenContract;

    address[] internal _approvalForSetTokenContract;

    constructor (address _owner) {}

    // add approval modifier for setTokenContract

    function setTokenContract(address tokenContract) external override {
        _tokenContract = TokenTemplate(tokenContract);
    }

    function invest(uint256 _amount, address _company) external {
        // call transfer or transferFrom 
    }

    function sellTokens(uint256 _amount, address _company) external {

    }
}