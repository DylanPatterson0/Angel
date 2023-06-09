//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ControllerTemplate.sol";
import "hardhat/console.sol";

contract TokenTemplate is ERC20, Ownable, Pausable {
    //max supply (number of tokens that can be issues)
    uint256 private _maxSupply;
    //market cap (amount of money company wants to raise)
    uint256 private _marketCap;
    uint256 private _tokenMintPrice;
    ControllerTemplate internal _controller;
    // account -> amount minted -> timestamp of minting
    mapping(address => mapping(uint256 => uint256)) internal _mintingTimestamps;
    mapping(address => uint256[]) internal _mints;
    mapping(address => uint256[]) internal _mintTimestamps;
    mapping(address => uint256[]) internal _mintAmounts;
    mapping(address => uint256) internal _mintIndex;
    mapping(address => uint256) internal _availableToTrade;
    event Minted(address account, uint256 amount, address token);

    modifier onlyController() {
        require(msg.sender == address(_controller), "Non-controller call");
        _;
    }

    constructor(
        string memory name,
        string memory symbol,
        uint256 maxSupply,
        uint256 marketCap
    ) ERC20(name, symbol) {
        _maxSupply = maxSupply;
        _marketCap = marketCap;
        _tokenMintPrice = marketCap / maxSupply;
    }

    function setControllerContract(
        address _controllerAddress
    ) external onlyOwner whenNotPaused {
        _controller = ControllerTemplate(_controllerAddress);
    }

    function burn(address account, uint256 amount) external onlyController {
        _burn(account, amount);
    }

    function getControllerContract() external view returns (address) {
        return address(_controller);
    }

    function mint(
        address account,
        uint256 amount
    ) public payable whenNotPaused onlyController {
        require(totalSupply() <= _maxSupply, "Max Supply Reached");
        //require(_tokenMintPrice = msg.value, "")
        _mints[account].push(amount);
        _mintTimestamps[account].push(block.timestamp);
        _mintAmounts[account].push(amount);
        _mint(account, amount);
        _mintIndex[account]++;
        emit Minted(account, amount, address(this));
    }

    function _beforeTokenTransfer(
        address account,
        address to,
        uint256 amount
    ) internal override {
        // address(0) is from address in mint
        // refer to ERC20.sol:262
        if (account == address(0)) {} else if (to == address(0)) {} else {
            uint256 index = _mintIndex[account];
            uint256 timeStampMinted = _mintTimestamps[account][index - 1];
            uint256 amountMinted = _mintAmounts[account][index - 1];
            // update amount available to trade based on time since mint
            if (block.timestamp - timeStampMinted > 24 weeks) {
                _availableToTrade[account] += amountMinted;
                _mintIndex[account]++;
            }
            // require that amount is less than or equal to tokens available for trade
            require(amount <= _availableToTrade[account], "Tokens locked up");
            // update amount availble to trade based on tokens spent
            _availableToTrade[account] -= amount;
        }
    }
}
