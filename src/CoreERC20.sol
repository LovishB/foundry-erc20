// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title CoreERC20
 * @dev CoreERC20 contract is a base contract for ERC20 tokens.
 * @author Lovish Badlani
 * It includes the basic functionality and variables of an ERC20 token.
 * Also checkout other ERC20s like Mintable/ Burnable/ Pausable/ Capped/ TimeLocked/ etc.
 */
contract CoreERC20 {

    // State Variables
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // Main Balance mapping: owner => balance
    // balanceOf() returns the amount of tokens owned by account.
    mapping (address => uint256) public balanceOf;

    // Allowance mapping: owner => spender => amount
    // allowance() returns the number of tokens that spender will be allowed to spend on behalf of owner.
    // like giving someone permission to spend your tokens
    mapping (address => mapping (address => uint256)) public allowance;

    //Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Custom Errors
    error DecimalsTooHigh(uint8 decimals);
    error InvalidSupply(uint256 supply);
    error ZeroAddress();
    error InsufficientBalance();
    error InsufficientAllowance();

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) {
        //Checks according to ERC20 standard
        if(_decimals > 18) {
            revert DecimalsTooHigh(_decimals);
        }
        if(_totalSupply == 0 || _totalSupply > 1000000000000) {
            revert InvalidSupply(_totalSupply);
        }
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balanceOf[msg.sender] = _totalSupply; //deployer gets all the tokens

        emit Transfer(address(0), msg.sender, _totalSupply); // Minting event
    }

    /*
     * @dev Transfer tokens from one address to another.
     * @param _recipient The address to transfer to.
     * @param _amount The amount to be transferred.
     * @return True if the transfer was successful.
     */
    function transfer(address _recipient, uint256 _amount) external returns (bool) {
        if(_recipient == address(0)) {
            revert ZeroAddress();
        }
        if(balanceOf[msg.sender] <_amount) {
            revert InsufficientBalance();
        }
        balanceOf[msg.sender] -= _amount;
        balanceOf[_recipient] += _amount;

        emit Transfer(msg.sender, _recipient, _amount);
        return true;
    }

    /*
     * @dev Allows spender to spend tokens on behalf of owner
     * @param _spender  The address which can spend the funds
     * @param _amount The amount to be spent.
     * @return Returns true if the operation succeeded
     */
    function approve(address _spender, uint256 _amount) external returns (bool) {
        if(_spender == address(0)) {
            revert ZeroAddress();
        }
        if(balanceOf[msg.sender] < _amount) {
            revert InsufficientBalance();
        }
        allowance[msg.sender][_spender] = _amount;

        emit Approval(msg.sender, _spender, _amount);
        return true;
    }

    /* 
     * @dev Transfer tokens from one address to another on behalf of owner
     * @param _sender owner of the tokens
     * @param _recipient The address to which the tokens are to be transferred
     * @param amount The amount to be transferred
     * @param msg.sender The address who wish to spend the funds
     * @return Returns true if the operation succeeded
     */
    function transferFrom(address _sender, address _recipient, uint256 amount) external returns (bool) {
        if(_sender == address(0) || _recipient == address(0)) {
            revert ZeroAddress();
        }
        if(balanceOf[_sender] < amount) { //check if owner has enough balance
            revert InsufficientBalance();
        }
        if(allowance[_sender][msg.sender] < amount) { //check if msg.sender has enough allowance
            revert InsufficientAllowance();
        }
        //Now the spender can transfer the tokens on behalf of owner
        allowance[_sender][msg.sender] -= amount;
        balanceOf[_sender] -= amount;
        balanceOf[_recipient] += amount;

        emit Transfer(_sender, _recipient, amount);
        return true;
    }

}