# Yellow Network Memed Token Battle Platform

A comprehensive DeFi platform that combines meme token creation, bonding curve trading, and competitive battling mechanics, designed for deployment on Yellow Network.

## 🚀 Quick Start

```bash
# Install dependencies
npm install

# Set up environment variables
npx hardhat vars set PRIVATE_KEY your_private_key_here
npx hardhat vars set YELLOW_RPC_URL https://rpc.yellow.org
npx hardhat vars set YELLOW_CHAIN_ID 12345

# Compile contracts
npm run compile

# Deploy to Yellow Network
npm run deploy:yellow
```

## 📋 Features

- **🎨 Meme Token Factory**: Create custom ERC20 tokens with metadata
- **📈 Bonding Curve Trading**: Dynamic pricing based on supply and demand  
- **⚔️ Token Battles**: Competitive battles between graduated tokens
- **🗳️ Voting System**: Anti-whale voting mechanism using square root of holdings
- **🏆 Leaderboards**: Comprehensive statistics and ranking system
- **🔒 Zero-Knowledge Proofs**: Groth16 verification for secure participation
- **🔄 Auto-Graduation**: Automatic DEX listing when tokens reach threshold

## 🏗️ Architecture

### Smart Contracts

- **YellowMemedFactory.sol**: Token creation, bonding curve trading, DEX graduation
- **YellowMemedBattle.sol**: Battle system with voting and statistics
- **MemedToken.sol**: ERC20 token with transfer controls
- **Verifier.sol**: Zero-knowledge proof verification

### Key Parameters

- **Creation Fee**: 0.002 Yellow Network tokens
- **Battle Fee**: 0.0002 Yellow Network tokens  
- **Graduation Threshold**: 0.005 Yellow Network tokens
- **Battle Duration**: 10 minutes
- **Min Battle Supply**: 1000 tokens

## 🛠️ Development

### Prerequisites

- Node.js v16+
- npm v7+
- Yellow Network wallet with native tokens

### Environment Setup

```bash
# Using Hardhat vars (recommended)
npx hardhat vars set PRIVATE_KEY your_private_key
npx hardhat vars set YELLOW_RPC_URL https://rpc.yellow.org
npx hardhat vars set YELLOW_CHAIN_ID 12345

# Or copy environment template
cp yellow-network.env.example .env
```

### Available Scripts

```bash
npm run compile          # Compile contracts
npm run test            # Run tests
npm run deploy:yellow   # Deploy to Yellow testnet
npm run deploy:yellow-mainnet  # Deploy to Yellow mainnet
```

### Testing

```bash
# Compile contracts
npx hardhat compile

# Run tests (if available)
npx hardhat test

# Local development
npx hardhat node
```

## 🚀 Deployment

### Quick Deploy

```bash
# Deploy both contracts to Yellow Network
npm run deploy:yellow
```

### Manual Deploy

```bash
# Deploy factory first
npx hardhat ignition deploy ./ignition/modules/deploy.ts --network yellowTestnet

# Update factory address in deployBattle.ts, then deploy battle
npx hardhat ignition deploy ./ignition/modules/deployBattle.ts --network yellowTestnet
```

### Contract Verification

```bash
npx hardhat verify --network yellowTestnet CONTRACT_ADDRESS [CONSTRUCTOR_ARGS]
```

## 📖 Usage Examples

### Creating a Meme Token

```javascript
const factory = await ethers.getContractAt("YellowMemedFactory", factoryAddress);
const tx = await factory.createMeme(
  "MyToken",
  "MTK", 
  "A test meme token",
  "https://example.com/image.png",
  { value: ethers.parseEther("0.002") }
);
```

### Trading Tokens

```javascript
// Buy tokens
const buyTx = await factory.buy(tokenAddress, amount, { value: requiredYellow });

// Sell tokens  
const sellTx = await factory.sell(tokenAddress, amount);
```

### Creating Battles

```javascript
const battle = await ethers.getContractAt("YellowMemedBattle", battleAddress);
const tx = await battle.createBattle(token1, token2, { 
  value: ethers.parseEther("0.0002") 
});
```

## ⚠️ Important Notes

1. **DEX Addresses**: Update the DEX factory and router addresses in `YellowMemedFactory.sol` with actual Yellow Network DEX addresses before deployment.

2. **Network Configuration**: Verify Yellow Network RPC URLs and chain IDs are correct for your deployment target.

3. **Security**: Never commit private keys. Use Hardhat's variable management or environment files excluded from version control.

## 📚 Documentation

- [Project Context](../PROJECT_CONTEXT.md) - Detailed project overview
- [Setup Guide](../SETUP_GUIDE.md) - Comprehensive setup instructions
- [Yellow Network Docs](https://docs.yellow.org/) - Official Yellow Network documentation

## 🔐 Security

This platform implements multiple security measures:
- Access control for critical functions
- Input validation and parameter checking
- Anti-whale voting mechanisms
- Zero-knowledge proof verification
- Safe math operations

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test thoroughly on Yellow Network testnet
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details

## 🆘 Support

For technical support:
1. Check the troubleshooting section in SETUP_GUIDE.md
2. Review Yellow Network documentation
3. Verify contract addresses and network configuration
