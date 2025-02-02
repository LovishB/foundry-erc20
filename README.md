# CoreERC20 Token Contract

A basic implementation of the ERC20 token standard with core functionality and custom error handling.

## Features

- Standard ERC20 functionality (transfer, approve, transferFrom)
- Custom error handling for better gas efficiency
- Supply cap of 1 trillion tokens
- Maximum 18 decimals
- Events for transfers and approvals

## Contract Functions

### Core Functions
- `transfer(address _recipient, uint256 _amount)`: Transfer tokens to another address
- `approve(address _spender, uint256 _amount)`: Approve address to spend tokens
- `transferFrom(address _sender, address _recipient, uint256 amount)`: Transfer tokens on behalf of another address

### View Functions
- `balanceOf(address)`: Get token balance of an address
- `allowance(address owner, address spender)`: Get approved spending amount
- `name()`: Get token name
- `symbol()`: Get token symbol
- `decimals()`: Get token decimals
- `totalSupply()`: Get total supply of tokens

## Error Handling

The contract includes custom errors for better gas efficiency:
- `DecimalsTooHigh`: When decimals > 18
- `InvalidSupply`: When supply is 0 or > 1 trillion
- `ZeroAddress`: When interacting with zero address
- `InsufficientBalance`: When trying to transfer more than balance
- `InsufficientAllowance`: When trying to transferFrom more than allowed

## Testing on Anvil

### Prerequisites
- Foundry installed
- Running Anvil instance

### Setup and Deployment

1. Start Anvil in a terminal:
```bash
anvil
```

2. Export environment variables:
```bash
# Export private key (Anvil's first account)
export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Deploy contract
forge create --private-key $PRIVATE_KEY \
    src/CoreERC20.sol:CoreERC20 \
    --broadcast \
    --rpc-url http://localhost:8545 \
    --constructor-args "MyToken" "MKT" 18 1000000

# Export test accounts
export OWNER=0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266  # First Anvil account
export RECIPIENT=0x70997970C51812dc3A010C7d01b50e0d17dc79C8  # Second Anvil account
export SPENDER=0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC  # Third Anvil account
export SPENDER_KEY=0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a

# Export deployed contract address (replace with actual address)
export CONTRACT=<deployed-contract-address>
```

### Testing Core Functions

1. Check Balances:
```bash
# Check owner's balance
cast call $CONTRACT "balanceOf(address)(uint256)" $OWNER

# Check recipient's balance
cast call $CONTRACT "balanceOf(address)(uint256)" $RECIPIENT
```

2. Test Transfer:
```bash
# Transfer 1000 tokens to RECIPIENT
cast send $CONTRACT "transfer(address,uint256)" $RECIPIENT 1000 \
    --private-key $PRIVATE_KEY \
    --rpc-url http://localhost:8545

# Verify balances after transfer
cast call $CONTRACT "balanceOf(address)(uint256)" $RECIPIENT
```

3. Test Approve and TransferFrom:
```bash
# Approve SPENDER to spend 500 tokens
cast send $CONTRACT "approve(address,uint256)" $SPENDER 500 \
    --private-key $PRIVATE_KEY \
    --rpc-url http://localhost:8545

# Check allowance
cast call $CONTRACT "allowance(address,address)(uint256)" $OWNER $SPENDER

# SPENDER transfers tokens from OWNER to RECIPIENT
cast send $CONTRACT "transferFrom(address,address,uint256)" $OWNER $RECIPIENT 300 \
    --private-key $SPENDER_KEY \
    --rpc-url http://localhost:8545
```

### Testing Error Cases

1. Test Insufficient Balance:
```bash
# Try to transfer more than balance
cast send $CONTRACT "transfer(address,uint256)" $RECIPIENT 999999999999 \
    --private-key $PRIVATE_KEY \
    --rpc-url http://localhost:8545
```

2. Test Zero Address:
```bash
# Try to transfer to zero address
cast send $CONTRACT "transfer(address,uint256)" 0x0000000000000000000000000000000000000000 100 \
    --private-key $PRIVATE_KEY \
    --rpc-url http://localhost:8545
```

3. Test Insufficient Allowance:
```bash
# Try to transferFrom more than allowed
cast send $CONTRACT "transferFrom(address,address,uint256)" $OWNER $RECIPIENT 1000 \
    --private-key $SPENDER_KEY \
    --rpc-url http://localhost:8545
```

## License
MIT