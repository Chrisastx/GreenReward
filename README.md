# GreenReward 🌱

A decentralized carbon credit marketplace built on Stacks blockchain, enabling transparent trading and retirement of verified carbon credits.

## Overview

GreenReward facilitates the creation, trading, and retirement of carbon credits through smart contracts, providing transparency and efficiency to the carbon offset market. Users can issue credits for environmental projects, trade them on the marketplace, and retire them to offset their carbon footprint.

## Features

- **Credit Issuance**: Create carbon credits with verified environmental projects
- **Batch Operations**: Efficient bulk issuance and retirement of multiple credits
- **Marketplace Trading**: Buy and sell credits with transparent pricing
- **Credit Retirement**: Permanently retire credits for carbon offsetting
- **User Balances**: Track owned and retired credits
- **Platform Fees**: Built-in fee structure for platform sustainability

## Smart Contract Functions

### Public Functions

#### Individual Operations
- `issue-credits`: Issue new carbon credits with project details
- `list-for-sale`: List credits for sale on the marketplace
- `purchase-credits`: Purchase available credits from sellers
- `retire-credits`: Permanently retire credits for offsetting
- `remove-from-sale`: Remove credits from marketplace
- `update-platform-fee`: Update platform fee (admin only)

#### Batch Operations
- `batch-issue-credits`: Issue multiple carbon credits in a single transaction
- `batch-retire-credits`: Retire multiple credits simultaneously for efficiency

### Read-Only Functions

- `get-credit-details`: Retrieve credit information
- `get-user-balance`: Get user's credit balance
- `get-marketplace-listing`: Get marketplace listing details
- `get-platform-fee`: Current platform fee
- `get-max-batch-size`: Maximum allowed batch size for operations
- `is-credit-available`: Check if credit is available for purchase

## Batch Operations

### Batch Credit Issuance

Issue multiple carbon credits in a single transaction for improved efficiency:

```clarity
(batch-issue-credits 
  (list 
    {amount: u100, price: u50, project-type: "Solar Farm", verification-standard: "VCS"}
    {amount: u200, price: u45, project-type: "Wind Power", verification-standard: "Gold Standard"}
  )
)
```

**Benefits:**
- Reduced transaction costs
- Improved efficiency for large-scale projects
- Atomic operations (all succeed or all fail)
- Maximum batch size: 50 credits per transaction

### Batch Credit Retirement

Retire multiple credits simultaneously:

```clarity
(batch-retire-credits (list u1 u2 u3 u4 u5))
```

**Benefits:**
- Streamlined offset reporting
- Bulk retirement for corporate sustainability
- Single transaction for multiple offsets
- Efficient portfolio management

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for transactions

### Installation

1. Clone the repository
2. Install dependencies with `clarinet check`
3. Deploy contract using `clarinet deploy`

### Usage

#### Individual Operations
1. **Issue Credits**: Call `issue-credits` with project details
2. **List for Sale**: Use `list-for-sale` to make credits available
3. **Purchase**: Call `purchase-credits` to buy available credits
4. **Retire**: Use `retire-credits` to permanently offset credits

#### Batch Operations
1. **Batch Issue**: Use `batch-issue-credits` with list of credit data
2. **Batch Retire**: Use `batch-retire-credits` with list of credit IDs

### Error Codes

- `u100`: Unauthorized access
- `u101`: Invalid amount
- `u102`: Insufficient balance
- `u103`: Credit not found
- `u104`: Credit already retired
- `u105`: Invalid price
- `u106`: Self-trade attempt
- `u107`: Invalid string input
- `u108`: Empty batch operation
- `u109`: Batch size too large

## Testing

Run the test suite with:
```bash
clarinet test
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request with detailed description
