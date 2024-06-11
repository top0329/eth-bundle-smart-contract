// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Token.sol";
import "hardhat/console.sol";

contract TokenFactory {
    address public devTokenContractAddress;
    event TokenCreated(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint8 decimals,
        uint256 totalSupply,
        address creator
    );

    function createToken(
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        uint8 _decimals,
        address creator,
        address uniswapV2Address
    ) public {
        TOKEN newToken = new TOKEN(_name, _symbol, _totalSupply, _decimals, uniswapV2Address);
        newToken.transferOwnership(creator);
        console.log("New Token address:", address(newToken));
        devTokenContractAddress = address(newToken);
        emit TokenCreated(
            address(newToken),
            _name,
            _symbol,
            _decimals,
            _totalSupply,
            creator
        );
    }
}
