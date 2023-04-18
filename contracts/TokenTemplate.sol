//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ControllerTemplate.sol";

contract TokenTemplate is ERC20 {
    ControllerTemplate internal _controller;

    // account -> amount minted -> timestamp of minting
    mapping(address => mapping(uint256 => uint256)) internal _mintingTimestamps;
    mapping(address => uint256[]) internal _mints;

    mapping(address => uint256[]) internal _mintTimestamps;
    mapping(address => uint256[]) internal _mintAmounts;
    mapping(address => uint256) internal _mintIndex;

    mapping(address => uint256) internal _availableToTrade;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply
    ) ERC20(_name, _symbol) {}

    function setControllerContract(address _controllerAddress) external {
        _controller = ControllerTemplate(_controllerAddress);
    }

    function getControllerContract() external view returns (address) {
        return address(_controller);
    }

    function mint(address account) public payable {
        _mintingTimestamps[account][block.timestamp] = msg.value;
        _mints[account].push(msg.value);
        _mint(account, msg.value);
    }

    function getAvailableToTrade(
        address account
    ) public view returns (uint256) {}

    function _beforeTokenTransfer(
        address from,
        address,
        uint256 amount
    ) internal override {
        uint256 index = _mintIndex[from];
        uint256 timeStampMinted = _mintTimestamps[from][index];
        uint256 amountMinted = _mintAmounts[from][index];

        // update amount available to trade based on time since mint
        if (block.timestamp - timeStampMinted > 24 weeks) {
            _availableToTrade[from] += amountMinted;
        }

        // require that amount is less than or equal to tokens available for trade
        require(amount <= _availbleToTrade[from], "Tokens locked up");
        
        // update amount availble to trade based on tokens spent
        _availableToTrade[from] -= amount;
    }

    
}
