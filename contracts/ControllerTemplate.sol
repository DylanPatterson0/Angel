//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TokenTemplate.sol";

interface IControllerTemplate {
    event Invested(address investor, uint256 amount, address company);
    event Sold(uint256 amount, address company, address buyer, address seller);

    function setTokenContract(address tokenContract) external;

    function invest(address account, uint256 amount) external;

    function sellTokens(address buyer, address seller, uint256 amount) external;

    function withdraw(address operator, uint256 amount) external;
}

contract ControllerTemplate is IControllerTemplate, Ownable, Pausable {
    TokenTemplate internal _tokenContract;
    address[] internal _approvalForSetTokenContract;
    address private _operator;
    uint256 _maxSupply;
    uint256 _marketCap;
    uint256 _tokenMintPrice;

    modifier onlyOperator() {
        require(msg.sender == address(_operator), "Non-operator call");
        _;
    }

    constructor(address operator, uint256 maxSupply, uint256 marketCap) {
        _operator = operator;
        _maxSupply = maxSupply;
        _marketCap = marketCap;
        _tokenMintPrice = marketCap / maxSupply;
    }

    // add approval modifier for setTokenContract
    function setTokenContract(
        address tokenContract
    ) external override onlyOwner {
        _tokenContract = TokenTemplate(tokenContract);
    }

    function invest(
        address account,
        uint256 amount
    ) external override whenNotPaused {
        require(msg.value = _tokenMintPrice * amount, "Wrong amount");
        _tokenContract.mint(account, amount);
        emit Invested(account, amount, address(_tokenContract));
    }

    function sellTokens(
        address buyer,
        address seller,
        uint256 amount
    ) external override whenNotPaused {
        _tokenContract.transferFrom(seller, buyer, amount);
        emit Sold(amount, address(_tokenContract), buyer, seller);
    }

    function withdraw(
        address operator,
        uint256 amount
    ) external override onlyOperator {
        payable(operator).transfer(amount);
    }
}
