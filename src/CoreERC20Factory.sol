// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {CoreERC20} from "./CoreERC20.sol";

/**
 * @title CoreERC20Factory
 * @dev Factory contract for creating new ERC20 tokens using CoreERC20 as the base contract
 * @author Lovish Badlani
 * The factory keeps track of all deployed tokens and ensures unique symbols.
 */
contract CoreERC20Factory {
    address[] private s_createdTokens;
    mapping(string => bool) private s_symbolExist;

    event TokenCreated(
        address indexed tokenAddress,
        string name,
        string symbol,
        uint8 decimals,
        uint256 totalSupply,
        address owner
    );

    error InvalidParameters();
    error SymbolAlreadyExist(string symbol);

    /**
     * @notice Creates a new ERC20 token with specified parameters
     * @dev Deploys a new instance of CoreERC20 contract and registers it in the factory
     * @param _name The name of the token
     * @param _symbol The symbol/ticker of the token
     * @param _decimals The number of decimals for token amounts
     * @param _totalSupply The initial total supply of the token
     * @return address The address of the newly created token contract
     * @custom:throws SymbolAlreadyExist if the symbol is already in use
     * @custom:throws InvalidParameters if any of the parameters are invalid
     */
    function createToken(
        string calldata _name, 
        string calldata _symbol, 
        uint8 _decimals, 
        uint256 _totalSupply
    ) external returns (address) {
        //check if symbol exist
        if(s_symbolExist[_symbol]) {
            revert SymbolAlreadyExist(_symbol);
        }

        //check invalid param
        if(bytes(_name).length == 0 || bytes(_symbol).length == 0 || _decimals == 0 || _totalSupply == 0) {
            revert InvalidParameters();
        }
        //deploy new token
        CoreERC20 newToken = new CoreERC20(_name, _symbol, _decimals, _totalSupply);
        address tokenAddress = address(newToken);
        
        //register new token
        s_createdTokens.push(address(newToken));
        s_symbolExist[_symbol] = true;

        //event emit
        emit TokenCreated(tokenAddress, _name, _symbol, _decimals, _totalSupply, msg.sender);
        return tokenAddress;
    }

    /**
     * @notice Checks if a token symbol is available for use
     * @dev Returns false if the symbol is already registered in the factory
     * @param _symbol The symbol to check availability for
     * @return bool True if the symbol is available, false if already taken
     */
    function isSymbolAvailable(string memory _symbol) external view returns (bool) {
        return !s_symbolExist[_symbol];
    }

    /**
     * @notice Returns the total number of tokens created by this factory
     * @dev Returns the length of the s_createdTokens array
     * @return uint256 The count of tokens created
     */
    function getTokenCount() external view returns (uint256) {
        return s_createdTokens.length;
    }
}