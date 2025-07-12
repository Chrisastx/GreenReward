# GreenReward 🌱

A decentralized carbon credit marketplace built on Stacks blockchain, enabling transparent trading and retirement of verified carbon credits.

## Overview

GreenReward facilitates the creation, trading, and retirement of carbon credits through smart contracts, providing transparency and efficiency to the carbon offset market. Users can issue credits for environmental projects, trade them on the marketplace, and retire them to offset their carbon footprint.

## Features

- **Credit Issuance**: Create carbon credits with verified environmental projects
- **Marketplace Trading**: Buy and sell credits with transparent pricing
- **Credit Retirement**: Permanently retire credits for carbon offsetting
- **User Balances**: Track owned and retired credits
- **Platform Fees**: Built-in fee structure for platform sustainability

## Smart Contract Functions

### Public Functions

- `issue-credits`: Issue new carbon credits with project details
- `list-for-sale`: List credits for sale on the marketplace
- `purchase-credits`: Purchase available credits from sellers
- `retire-credits`: Permanently retire credits for offsetting
- `remove-from-sale`: Remove credits from marketplace
- `update-platform-fee`: Update platform fee (admin only)

### Read-Only Functions

- `get-credit-details`: Retrieve credit information
- `get-user-balance`: Get user's credit balance
- `get-marketplace-listing`: Get marketplace listing details
- `get-platform-fee`: Current platform fee
- `is-credit-available`: Check if credit is available for purchase

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for transactions

### Installation

1. Clone the repository
2. Install dependencies with `clarinet check`
3. Deploy contract using `clarinet deploy`

### Usage

1. **Issue Credits**: Call `issue-credits` with project details
2. **List for Sale**: Use `list-for-sale` to make credits available
3. **Purchase**: Call `purchase-credits` to buy available credits
4. **Retire**: Use `retire-credits` to permanently offset credits

## Testing

Run the test suite with:
```bash
clarinet test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description

