# Yellow Network Memed Token Battle Platform - Project Context

## Overview

This is a comprehensive DeFi platform built on Solidity that combines meme token creation, trading, and competitive battling mechanics. The platform consists of multiple interconnected smart contracts designed for deployment on Yellow Network.

## Core Concepts

### 1. **Meme Token Factory System**
- **Token Creation**: Users can create custom ERC20 meme tokens with metadata (name, ticker, description, image)
- **Bonding Curve Trading**: Tokens start in a "bonding curve" phase where price increases with supply
- **Graduation Mechanism**: When tokens reach 0.005 Yellow Network tokens collateral, they "graduate" to Yellow DEX with automatic liquidity provision

### 2. **Battle System**
- **Token Battles**: Graduated tokens can battle each other in timed competitions (10 minutes)
- **Voting Mechanism**: Users vote using their token holdings as voting power (square root to prevent whale dominance)
- **Leaderboard & Stats**: Comprehensive tracking of wins, losses, and monthly performance
- **King System**: Tokens that win 3+ battles in a month become "King"

### 3. **Zero-Knowledge Proof Integration**
- **Battle Ticket Verifier**: Groth16 proof system for secure battle participation verification
- **Privacy-Preserving**: Allows users to prove eligibility without revealing sensitive data

## Smart Contract Architecture

### Core Contracts

#### 1. **MemedToken.sol**
```solidity
- ERC20 token with transfer restrictions
- Owner-controlled minting/burning
- Transfer enabling mechanism for graduation
```

#### 2. **YellowMemedFactory.sol**
```solidity
- Token creation and management
- Bonding curve trading logic
- Automatic Yellow DEX graduation
- Fee collection and management
```

#### 3. **YellowMemedBattle.sol**
```solidity
- Battle creation and management
- Voting system with anti-whale mechanics
- Comprehensive statistics tracking
- Leaderboard and ranking system
```

#### 4. **Verifier.sol (battle_ticket_verifier.sol)**
```solidity
- Groth16 zero-knowledge proof verification
- Battle participation authentication
- Privacy-preserving user verification
```

## Key Features

### Trading Mechanics
- **Creation Fee**: 0.002 Yellow Network tokens to create a new token
- **Trade Fee**: 10% on all buy/sell transactions
- **Graduation Threshold**: 0.005 Yellow Network tokens in collateral
- **Bonding Curve**: Linear price increase based on supply

### Battle System
- **Battle Duration**: 10 minutes per battle
- **Creation Fee**: 0.0002 Yellow Network tokens per battle
- **Cooldown Period**: 10 minutes between same token pair battles
- **Voting Power**: Square root of token balance to prevent whale dominance
- **Minimum Supply**: 1000 tokens required for battle participation

### Economic Model
- **Max Supply**: 1 billion tokens per meme token
- **Liquidity Provision**: 20% of max supply + 98% of graduation collateral to Yellow DEX
- **Creator Reward**: 2% of graduation collateral to token creator
- **Fee Distribution**: Platform fees collected in Yellow Network native currency

## Deployment Information

### Yellow Network Deployments
- **YellowMemedFactory**: To be deployed on Yellow Network
- **YellowMemedBattle**: To be deployed on Yellow Network
- **Network**: Yellow Network Testnet/Mainnet

### External Dependencies
- **Yellow DEX Factory**: To be configured with actual Yellow Network DEX addresses
- **Yellow DEX Router**: To be configured with actual Yellow Network DEX addresses
- **OpenZeppelin Contracts**: v5.1.0
- **Uniswap V2 Core/Periphery**: For DEX interface compatibility

## Technology Stack

### Smart Contracts
- **Solidity**: v0.8.28
- **Hardhat**: Development framework
- **OpenZeppelin**: Security-audited contract libraries
- **Hardhat Ignition**: Deployment management

### Zero-Knowledge Proofs
- **Groth16**: Proof system for battle verification
- **BN254 Curve**: Elliptic curve for cryptographic operations
- **Custom Verifier**: Tailored for battle ticket validation

### Development Tools
- **TypeScript**: Configuration and deployment scripts
- **Hardhat Toolbox**: Complete development suite
- **Yellow Network**: Primary deployment target

## User Journey

### Token Creator Flow
1. Pay creation fee (0.002 Yellow Network tokens)
2. Deploy custom ERC20 token with metadata
3. Token enters bonding curve trading phase
4. Users buy/sell tokens at dynamic prices
5. When 0.005 Yellow Network tokens collateral reached, token graduates to Yellow DEX
6. Creator receives 2% of graduation collateral

### Battle Participant Flow
1. Hold graduated tokens (min 1000 tokens)
2. Create or join battles (0.0002 Yellow Network tokens fee)
3. Vote for preferred token during 10-minute battle
4. Voting power = sqrt(token holdings)
5. Winner determined by total votes
6. Stats tracked for leaderboards and king status

### Trader Flow
1. Discover tokens in bonding curve phase
2. Buy tokens at current bonding curve price
3. Sell tokens back to curve or wait for graduation
4. Trade on Yellow DEX after graduation
5. Participate in battles using token holdings

## Security Features

- **Access Control**: Owner-only functions for critical operations
- **Input Validation**: Comprehensive parameter checking
- **Reentrancy Protection**: Safe external calls
- **Mathematical Safety**: Overflow/underflow protection
- **Zero-Knowledge Proofs**: Privacy-preserving verification

## Future Expansion Possibilities

- **Multi-chain Deployment**: Expand to other EVM networks
- **Advanced Battle Types**: Tournament brackets, team battles
- **NFT Integration**: Battle rewards as collectible NFTs
- **Governance Token**: Platform governance and fee sharing
- **Advanced Analytics**: Detailed token and battle metrics

This platform represents a novel combination of DeFi mechanics, gamification, and privacy-preserving technology, creating an engaging ecosystem for meme token creation and competitive trading.
