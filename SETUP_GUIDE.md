# Yellow Network Memed Token Battle Platform - Setup Guide

## Prerequisites

### Required Software
- **Node.js**: v16.0.0 or higher
- **npm**: v7.0.0 or higher (comes with Node.js)
- **Git**: For version control

### Required Accounts
- **Yellow Network Wallet**: MetaMask or similar configured for Yellow Network
- **Yellow Network Tokens**: Native tokens for deployment and testing
- **Yellow Network Explorer API Key**: For contract verification (optional)

### Get Yellow Network Tokens
1. Configure your wallet for Yellow Network (see network configuration below)
2. Obtain Yellow Network tokens through faucet or exchange
3. Minimum tokens recommended for deployments and testing

## Installation

### 1. Clone and Install Dependencies

```bash
# Navigate to the contracts directory
cd contracts

# Install dependencies
npm install
```

### 2. Environment Configuration

Use Hardhat's built-in variable management:

```bash
# Set your private key securely
npx hardhat vars set PRIVATE_KEY your_private_key_here

# Set Yellow Network RPC URL
npx hardhat vars set YELLOW_RPC_URL https://rpc.yellow.org

# Set Yellow Network Chain ID  
npx hardhat vars set YELLOW_CHAIN_ID 12345

# Set Yellow Network Explorer API key (optional)
npx hardhat vars set YELLOW_EXPLORER_API_KEY your_explorer_api_key
```

Alternatively, you can copy the example environment file:

```bash
# Copy the example file
cp yellow-network.env.example .env
# Edit .env with your actual values
```

**⚠️ Security Warning**: Never commit your private keys or share them publicly!

### 3. Hardhat Configuration

The project uses Hardhat with the following configuration:

```typescript
// hardhat.config.ts
import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-ignition";

const config: HardhatUserConfig = {
  networks: {
    yellowTestnet: {
      url: vars.get('YELLOW_RPC_URL', 'https://rpc.yellow.org'),
      chainId: parseInt(vars.get('YELLOW_CHAIN_ID', '12345')),
      accounts: [vars.get('PRIVATE_KEY')],
    },
    yellowMainnet: {
      url: vars.get('YELLOW_MAINNET_RPC_URL', 'https://mainnet-rpc.yellow.org'),
      chainId: parseInt(vars.get('YELLOW_MAINNET_CHAIN_ID', '54321')),
      accounts: [vars.get('PRIVATE_KEY')],
    },
  },
  etherscan: {
    apiKey: {
      yellowTestnet: vars.get('YELLOW_EXPLORER_API_KEY', ''),
      yellowMainnet: vars.get('YELLOW_EXPLORER_API_KEY', ''),
    },
  },
  solidity: "0.8.28",
};
```

## Deployment

### Deploy to Yellow Network

#### Method 1: Using Deployment Script (Recommended)

```bash
# Deploy to Yellow Network Testnet
npm run deploy:yellow

# Or deploy to Yellow Network Mainnet
npm run deploy:yellow-mainnet
```

#### Method 2: Using Hardhat Ignition

```bash
# Deploy Factory contract
npx hardhat ignition deploy ./ignition/modules/deploy.ts --network yellowTestnet

# Deploy Battle contract (update factory address first)
npx hardhat ignition deploy ./ignition/modules/deployBattle.ts --network yellowTestnet
```

#### Method 3: Direct Script Execution

```bash
# Deploy to testnet
npx hardhat run scripts/deploy.ts --network yellowTestnet

# Deploy to mainnet
npx hardhat run scripts/deploy.ts --network yellowMainnet
```

#### Verify Contracts (Optional)

```bash
# Verify Factory contract
npx hardhat verify --network yellowTestnet FACTORY_ADDRESS

# Verify Battle contract  
npx hardhat verify --network yellowTestnet BATTLE_ADDRESS FACTORY_ADDRESS
```

## Testing

### Compile Contracts

```bash
# Compile all contracts
npx hardhat compile
```

### Run Local Tests

```bash
# Run all tests (if test files exist)
npx hardhat test

# Run tests with gas reporting
REPORT_GAS=true npx hardhat test
```

### Local Development Network

```bash
# Start local Hardhat network
npx hardhat node

# In another terminal, deploy to local network
npx hardhat ignition deploy ./ignition/modules/deploy.ts --network localhost
```

## Usage Examples

### Interacting with Contracts

#### Using Hardhat Console

```bash
# Start console connected to BSC Testnet
npx hardhat console --network bscTestnet
```

```javascript
// Get contract instances
const Factory = await ethers.getContractFactory("Factory");
const factory = Factory.attach("0x2ebE9162A3c629c6e23689DD302A8efA1AcA6c3B");

const MemedBattle = await ethers.getContractFactory("MemedBattle");
const battle = MemedBattle.attach("0x6250550d1413F517C58095C248c45aFbF38E4Ff8");

// Create a new meme token
const tx = await factory.createMeme(
  "TestToken",
  "TEST", 
  "A test token for the platform",
  "https://example.com/image.png",
  { value: ethers.utils.parseEther("0.002") }
);
await tx.wait();

// Get all tokens
const tokens = await factory.getTokens("0x0000000000000000000000000000000000000000");
console.log("Created tokens:", tokens);
```

#### Creating and Managing Battles

```javascript
// Assume you have two graduated token addresses
const token1 = "0x...";
const token2 = "0x...";

// Create a battle
const battleTx = await battle.createBattle(token1, token2, {
  value: ethers.utils.parseEther("0.0002")
});
await battleTx.wait();

// Vote in a battle
const voteTx = await battle.vote(0, token1); // Battle ID 0, vote for token1
await voteTx.wait();

// Settle battle after it ends
const settleTx = await battle.settleBattle(0);
await settleTx.wait();
```

## Project Structure

```
contracts/
├── contracts/
│   ├── contracts/           # Smart contract source files
│   │   ├── MemedToken.sol      # ERC20 token implementation
│   │   ├── MemedFactory.sol    # Token factory and trading
│   │   ├── MemedBattle.sol     # Battle system
│   │   └── battle_ticket_verifier.sol  # ZK proof verifier
│   ├── ignition/
│   │   ├── modules/            # Deployment modules
│   │   └── deployments/        # Deployment artifacts
│   ├── scripts/                # Deployment scripts
│   ├── hardhat.config.ts       # Hardhat configuration
│   ├── package.json           # Dependencies
│   └── tsconfig.json          # TypeScript config
├── PROJECT_CONTEXT.md         # Project overview and context
└── SETUP_GUIDE.md            # This setup guide
```

## Contract Functions Reference

### Factory Contract Functions

#### Public Functions
- `createMeme(name, ticker, description, image)` - Create new meme token (0.002 ETH fee)
- `buy(token, amount)` - Buy tokens on bonding curve
- `sell(token, amount)` - Sell tokens back to curve
- `getTokens(token)` - Get token information
- `getBNBAmount(token, amount)` - Calculate BNB required for trade

#### Owner Functions
- `setGraduationAmount(amount)` - Set graduation threshold
- `withdrawFees()` - Withdraw collected fees

### Battle Contract Functions

#### Public Functions
- `createBattle(token1, token2)` - Create new battle (0.0002 ETH fee)
- `vote(battleId, votingFor)` - Vote in active battle
- `settleBattle(battleId)` - Settle completed battle
- `getLeaderboard(limit)` - Get top performing tokens
- `getBattles(activeOnly)` - Get battle information
- `getTokenBasicStats(token)` - Get token battle statistics

#### View Functions
- `calculateVotingPower(voter, token1, token2)` - Calculate user's voting power
- `getTokenMonthlyStats(token)` - Get monthly performance data

## Troubleshooting

### Common Issues

#### 1. "Insufficient funds" Error
- Ensure wallet has enough BNB for gas fees
- Check if you're sending the correct fee amount for transactions

#### 2. "Network not found" Error
- Verify BSC Testnet is added to your wallet
- Check RPC URL in hardhat.config.ts

#### 3. "Contract not found" Error
- Ensure contract addresses are correct
- Verify contracts are deployed to the correct network

#### 4. "Transaction reverted" Error
- Check contract requirements (minimum balances, time restrictions, etc.)
- Verify you're calling functions with correct parameters

### Getting Help

1. **Check Contract Events**: Use BSCScan to view transaction logs
2. **Hardhat Console**: Use for debugging and testing function calls
3. **Gas Estimation**: Use `estimateGas()` to check transaction requirements
4. **Network Status**: Verify BSC Testnet is operational

## Security Best Practices

### Development
- Never commit private keys or sensitive data
- Use environment variables for configuration
- Test thoroughly on testnet before mainnet deployment
- Audit contracts before production use

### Deployment
- Verify contract source code on BSCScan
- Use multi-signature wallets for production deployments
- Implement timelock contracts for critical functions
- Monitor contract interactions and events

### User Safety
- Always verify contract addresses
- Start with small amounts for testing
- Understand tokenomics and risks
- Keep private keys secure

## Next Steps

1. **Frontend Integration**: Build web interface for user interactions
2. **Mobile App**: Create mobile application for token battles
3. **Analytics Dashboard**: Implement comprehensive statistics tracking
4. **Governance System**: Add community governance features
5. **Cross-chain Expansion**: Deploy to additional networks

## Support Resources

- **Hardhat Documentation**: https://hardhat.org/docs
- **OpenZeppelin Contracts**: https://docs.openzeppelin.com/contracts
- **BSC Documentation**: https://docs.binance.org/smart-chain/
- **Solidity Documentation**: https://docs.soliditylang.org/

For technical support or questions about this project, please refer to the contract source code and deployment artifacts in the repository.
