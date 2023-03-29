//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface ControllerTemplate {
    event Invested(address _amount, address _investor, address _company);
    event Sold(address _company, address _buyer, address _seller);

    function invest(uint256 _amount, address _company) external;

    function sellTokens(uint256 _amount, address _company) external;
}