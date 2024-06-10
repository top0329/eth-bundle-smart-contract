// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Token.sol";

contract TokenFactory {
    event TokenCreated(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint8 decimals,
        uint256 totalSupply
    );

    function createToken(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalSupply
    ) public {
        TOKEN newToken = new TOKEN(_name, _symbol, _totalSupply, _decimals);
        newToken.transfer(msg.sender, newToken.totalSupply());
        emit TokenCreated(
            address(newToken),
            _name,
            _symbol,
            _decimals,
            _totalSupply
        );
    }
}
