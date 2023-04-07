//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ControllerTemplate.sol";

contract TokenTemplate is ERC20 {

    ControllerTemplate internal _controller;

    // account -> amount minted -> timestamp of minting
    mapping (address => mapping (uint256 => uint256)) internal _mintingTimestamps;
    mapping (address => uint256[]) internal _mints;


    mapping(address => uint256[]) internal _mintTimestamps;
    mapping(address => uint256[]) internal _mintAmounts;
    mapping(address => uint256) internal _mintIndex;

    mapping(address => uint256) internal _availbleToTrade;

    constructor(string memory _name, string memory _symbol, uint256 _maxSupply) ERC20(_name, _symbol) {

    }

    function setControllerContract(address _controllerAddress) external {
        _controller = ControllerTemplate(_controllerAddress);
    }

    function getControllerContract() external {
        // return address(_controller); 
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {

        uint256 index = _mintIndex[from];
        uint256 timeStampMinted = _mintTimestamps[from][index];
        uint256 amountMinted = _mintAmounts[from][index];

        if (now - timeStampMinted)
        // uint256 availableToTrade = 
    }

    function mint(address account) public payable {
        _mintingTimestamps[account][now] = msg.value;
        _mints[account].push(msg.value);
        _mint(account, msg.value);
    }

}