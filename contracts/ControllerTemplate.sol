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

    constructor(address _owner) {}

    // add approval modifier for setTokenContract

    function setTokenContract(address tokenContract) external override {
        _tokenContract = TokenTemplate(tokenContract);
    }

    function invest(
        address account,
        uint256 amount
    ) external override whenNotPaused {
        // call transfer or transferFrom
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

    function withdraw(address operator, uint256 amount) external override {
        require(
            _tokenContract.balanceOf(operator) >= amount,
            "Insufficient Funds"
        );

        _tokenContract.burn(operator, amount);
    }
}
