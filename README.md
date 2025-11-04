A decentralized marketplace for DIY tech blueprints built on the Stacks blockchain using Clarity smart contracts. 

## 🚀 Overview

The DIY Tech Blueprint Marketplace solves the problem of secure, censorship-resistant publishing and monetization of technical innovations. Creators can mint their blueprints as NFTs and sell them with built-in licensing conditions, while buyers get secure access to innovative designs and schematics.

## ✨ Features

- 🎨 **Blueprint NFTs**: Mint blueprints as unique NFTs with metadata
- 💰 **License Marketplace**: Purchase one-time licenses for blueprints
- 🔀 **Blueprint Forking**: Create derivative blueprints with attribution
- � **Version Control**: Track blueprint versions and changes on-chain
- 👥 **Contributor System**: Add contributors and manage profit sharing
- 🏆 **DAO Grants**: Award grants to open-source builders
- 📊 **Creator Stats**: Track creator reputation and sales
- 🛡️ **Blueprint Auctions**: Time-based auctions for competitive pricing
- 🐛 **Issue Reporting**: Licensed users can report bugs and issues with blueprints

## 🛠️ Smart Contract Functions

### Core Functions

#### `mint-blueprint`
Create a new blueprint NFT with licensing terms.

```clarity
(mint-blueprint title description category price license-type is-open-source ipfs-hash)
```

**Parameters:**
- `title`: Blueprint title (max 64 chars)
- `description`: Blueprint description (max 256 chars) 
- `category`: Category (max 32 chars)
- `price`: License price in STX microunits
- `license-type`: Type of license (max 16 chars)
- `is-open-source`: Boolean for open source status
- `ipfs-hash`: IPFS hash for blueprint files (max 64 chars)

#### `purchase-license`
Buy a license to access a blueprint.

```clarity
(purchase-license blueprint-id)
```

**Parameters:**
- `blueprint-id`: ID of the blueprint to license

#### `add-version`
Add a new version to an existing blueprint.

```clarity
(add-version blueprint-id ipfs-hash changelog)
```

**Parameters:**
- `blueprint-id`: ID of the blueprint
- `ipfs-hash`: IPFS hash for new version files
- `changelog`: Description of changes (max 256 chars)

### Management Functions

#### `add-contributor`
Add a contributor to a blueprint (creator only).

```clarity
(add-contributor blueprint-id contributor share-percentage)
```

#### `award-dao-grant`
Award a DAO grant to an open-source blueprint (contract owner only).

```clarity
(award-dao-grant blueprint-id amount)
```

#### `update-marketplace-fee`
Update the marketplace fee rate (contract owner only).

```clarity
(update-marketplace-fee new-fee-rate)
```

#### `start-auction`
Initiate an auction for a blueprint.

```clarity
(start-auction blueprint-id duration starting-price)
```

**Parameters:**
- `blueprint-id`: ID of the blueprint
- `duration`: Auction duration in blocks
- `starting-price`: Minimum bid amount

#### `place-bid`
Place a bid on an active auction.

```clarity
(place-bid blueprint-id bid-amount)
```

**Parameters:**
- `blueprint-id`: ID of the blueprint
- `bid-amount`: Bid amount in STX

#### `end-auction`
End an auction and award the license to the highest bidder.

```clarity
(end-auction blueprint-id)
```

**Parameters:**
- `blueprint-id`: ID of the blueprint

#### `report-issue`
Report a bug or issue with a blueprint (licensed users only).

```clarity
(report-issue blueprint-id title description severity)
```

**Parameters:**
- `blueprint-id`: ID of the blueprint
- `title`: Issue title (max 128 chars)
- `description`: Issue description (max 500 chars)
- `severity`: Severity level (1-5, 1=low, 5=critical)

#### `resolve-issue`
Resolve an issue (creator only).

```clarity
(resolve-issue blueprint-id issue-id)
```

**Parameters:**
- `blueprint-id`: ID of the blueprint
- `issue-id`: ID of the issue to resolve

### Read-Only Functions

- `get-blueprint`: Get blueprint details
- `get-blueprint-version`: Get specific version details
- `get-license`: Check license status for a user
- `has-license`: Boolean check if user has license
- `get-contributor`: Get contributor details
- `get-creator-stats`: Get creator statistics
- `get-dao-grant`: Get grant details
- `get-marketplace-fee-rate`: Get current fee rate
- `get-next-blueprint-id`: Get next available blueprint ID
- `get-auction`: Get auction details
- `get-issue`: Get issue details
- `get-next-issue-id`: Get next available issue ID

## 🏁 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for testing

### Installation

1. Clone the repository
2. Run `clarinet check` to verify contract syntax
3. Run `npm install` to install dependencies
4. Run `npm test` to run tests

### Usage Example

```typescript
// Deploy the contract
clarinet deploy

// Mint a blueprint
(contract-call? .DIY-Tech-Blueprint-Marketplace mint-blueprint 
  "Arduino LED Controller" 
  "Complete schematic and code for RGB LED strip controller"
  "Electronics"
  u100000000  // 100 STX
  "commercial"
  false
  "QmX7YvPiKGf2hGkjvDrEKzFqV3o4J8mKs9"
)

// Purchase a license
(contract-call? .DIY-Tech-Blueprint-Marketplace purchase-license u1)

// Check if user has license
(contract-call? .DIY-Tech-Blueprint-Marketplace has-license u1 'ST1HTBVD3JG9C05J7HBJTHGR0GGW7KXW28M5JS8QE)
```

## 💡 Blueprint Categories

- 🔌 **Electronics**: Circuit designs, PCB layouts, sensor configurations
- 🤖 **Robotics**: Robot designs, servo controllers, automation systems  
- 🏠 **Home Automation**: IoT devices, smart home systems
- 🚗 **Automotive**: Car modifications, diagnostic tools
- 🔧 **Tools**: Custom tools, jigs, fixtures
- 🎮 **Gaming**: Controller mods, arcade systems
- 🌱 **Sustainability**: Solar systems, energy monitoring

## 🔒 Security Features

- Built-in marketplace fee collection
- License validation before access
- Creator ownership verification
- Version control with contributor tracking
- DAO governance for grants
- Issue tracking system for quality assurance

## 📈 Marketplace Economics

- **Marketplace Fee**: 2.5% (250 basis points) default fee
- **Creator Revenue**: 97.5% of purchase price goes to creator
- **Open Source Incentives**: DAO grants available for open-source projects
- **Contributor Rewards**: Profit sharing system for collaborations
- **Auction Dynamics**: Time-based auctions enable competitive pricing and higher potential earnings

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Add tests for new functionality
4. Run `clarinet check` and `npm test`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙋‍♂️ Support

For questions and support:
- Create an issue on GitHub
- Join our Discord community
- Check the documentation wiki

---

**Built with ❤️ for the DIY community** 🛠️✨
