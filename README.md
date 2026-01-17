# GreenReward 🌱

A decentralized carbon credit marketplace built on Stacks blockchain, enabling transparent trading and retirement of verified carbon credits with **automated IoT sensor verification**, **flexible credit fractionalization**, and **direct peer-to-peer transfers**.

## Overview

GreenReward facilitates the creation, trading, and retirement of carbon credits through smart contracts, providing transparency and efficiency to the carbon offset market. Users can issue credits for environmental projects, trade them on the marketplace, and retire them to offset their carbon footprint. **NEW**: Real-time environmental data validation through IoT sensor integration ensures project authenticity and impact measurement. **LATEST**: Credit fractionalization enables splitting and merging of carbon credits for flexible portfolio management. **🆕 Direct Transfer**: Send credits directly to other users without marketplace fees.

## Features

- **Credit Issuance**: Create carbon credits with verified environmental projects
- **🆕 Credit Fractionalization**: Split credits into smaller denominations (2-50 fractions) or merge fractional credits
- **🆕 Direct Transfer**: Send credits peer-to-peer without marketplace fees or listings
- **Flexible Trading**: Trade whole credits or fractional units for better liquidity
- **IoT Sensor Integration**: Real-time environmental monitoring and automated verification
- **Oracle Network**: Authorized data oracles for sensor reading validation  
- **Batch Operations**: Efficient bulk issuance and retirement of multiple credits
- **Marketplace Trading**: Buy and sell credits with transparent pricing
- **Credit Retirement**: Permanently retire credits for carbon offsetting
- **User Balances**: Track owned and retired credits
- **Platform Fees**: Built-in fee structure for platform sustainability (max 10%)
- **Verification Status**: Track credit verification through IoT data
- **Safe Arithmetic**: Overflow protection for all mathematical operations
- **Transfer History**: Complete audit trail of all credit transfers

## Direct Credit Transfer 🔄

### What is Direct Transfer?

The new transfer feature allows users to:
- **Send credits directly** to any valid Stacks address
- **No marketplace fees** - transfers are free (only gas costs)
- **Instant ownership** transfer with on-chain proof
- **Gift or donate** credits to environmental organizations
- **Transfer history** - complete audit trail of all movements

### Transfer Benefits

#### For Users
- **Zero Fees**: No platform commission on direct transfers
- **Privacy**: Transfer without public marketplace listing
- **Flexibility**: Send to anyone, anytime
- **Corporate Use**: Easy distribution to employees or partners
- **Charitable Giving**: Direct donations to environmental causes

#### For Organizations
- **Bulk Distribution**: Easily allocate credits to members
- **Transparent Gifting**: Provable carbon offset donations
- **Internal Trading**: Move credits between departments
- **Partner Rewards**: Incentivize sustainability partners

### Transfer Rules

#### Valid Transfers
- ✅ Must own the credit
- ✅ Credit cannot be retired
- ✅ Credit cannot be listed for sale
- ✅ Recipient must be a valid principal
- ✅ Cannot transfer to yourself
- ✅ Full credit amount transferred atomically

#### Transfer Process
```clarity
;; Transfer a credit to another user
(contract-call? .greenreward transfer-credit u1 'ST1RECIPIENT...)
;; Returns: transfer ID for audit trail
```

### Transfer History

Every transfer is recorded with:
- **From Address**: Original owner
- **To Address**: New owner
- **Credit ID**: Transferred credit
- **Amount**: Number of credit units
- **Date**: Block height of transfer
- **Transfer ID**: Unique identifier for the transaction

## Credit Fractionalization 🔀

### What is Fractionalization?

Credit fractionalization allows users to:
- **Split large credits** into smaller, more tradeable units (2-50 fractions)
- **Merge fractional credits** back into larger denominations
- **Improve liquidity** by offering smaller investment sizes
- **Flexible portfolio management** for diverse trading strategies

### Key Benefits

#### For Credit Owners
- **Better Liquidity**: Sell portions of large credits without liquidating entire holdings
- **Price Optimization**: Test different price points with smaller units
- **Portfolio Diversification**: Distribute credits across multiple buyers
- **Strategic Trading**: Hold some fractions while selling or transferring others

#### For Buyers
- **Lower Entry Barriers**: Purchase smaller amounts that fit budgets
- **Incremental Investing**: Build carbon offset portfolios gradually
- **Risk Management**: Diversify across multiple fractional credits
- **Market Access**: Access high-value projects through fractional ownership

#### For the Market
- **Increased Liquidity**: More trading opportunities with flexible denominations
- **Market Efficiency**: Better price discovery through granular trading
- **Accessibility**: Democratized access to carbon credit markets
- **Innovation**: New trading strategies and market dynamics

### Fractionalization Rules

#### Splitting Credits
- ✅ Credits must be owned by the user
- ✅ Credits cannot be listed for sale
- ✅ Credits cannot be retired
- ✅ Credits cannot already be fractional (no double-fractionalization)
- ✅ Minimum 2 fractions, maximum 50 fractions per credit
- ✅ Each fraction must contain at least 1 credit unit
- ✅ Original credit is retired when fractionalized

#### Merging Credits
- ✅ All fractions must be owned by the user
- ✅ Minimum 2 fractional credits required for merging
- ✅ All fractions must be from the same project type
- ✅ Fractions cannot be listed for sale
- ✅ Fractions cannot be retired
- ✅ Original fractions are retired after merging
- ✅ Merged credit inherits all properties from fractional credits

## Smart Contract Functions

### Credit Management

#### Individual Operations
- `issue-credits(amount, price, project-type, verification-standard, sensor-id)`: Issue new carbon credits with optional IoT sensor integration
- `transfer-credit(credit-id, recipient)`: 🆕 Transfer credit directly to another user
- `list-for-sale(credit-id, price-per-credit)`: List credits for sale on the marketplace
- `purchase-credits(credit-id, amount)`: Purchase available credits from sellers with platform fee
- `retire-credits(credit-id)`: Permanently retire credits for offsetting
- `remove-from-sale(credit-id)`: Remove credits from marketplace

#### Batch Operations
- `batch-issue-credits(credits-data)`: Issue up to 50 carbon credits in a single transaction with IoT support
- `batch-retire-credits(credit-ids)`: Retire multiple credits simultaneously (up to 50 credits)

### Fractionalization Functions 🆕

#### Credit Splitting & Merging
- `fractionalize-credit(credit-id, number-of-fractions)`: Split a credit into 2-50 smaller denominations
- `merge-fractional-credits(fraction-ids)`: Merge multiple fractional credits into one credit

### IoT Integration Functions

#### Sensor Management
- `register-iot-sensor(sensor-address, project-location, sensor-type, verification-threshold)`: Register IoT sensor for environmental monitoring
- `submit-sensor-reading(sensor-id, co2-reduction, energy-generated, trees-planted)`: Submit verified sensor data (oracle only)
- `verify-credits-with-sensor(credit-id)`: Verify credits using IoT sensor data against thresholds

#### Oracle Management
- `authorize-oracle(oracle)`: Authorize oracle for sensor data submission (admin only)
- `revoke-oracle(oracle)`: Revoke oracle authorization (admin only)

#### Admin Functions
- `update-platform-fee(new-fee)`: Update platform fee (max 10%, admin only)
- `deactivate-sensor(sensor-id)`: Deactivate sensor (admin only)

### Read-Only Functions

#### Credit Information
- `get-credit-details(credit-id)`: Retrieve complete credit information including verification status
- `get-user-balance(user)`: Get user's total credits and retired credits
- `get-marketplace-listing(credit-id)`: Get marketplace listing details
- `is-credit-available(credit-id)`: Check if credit is available for purchase
- `is-credit-verified(credit-id)`: Check if credit is IoT verified
- `get-transfer-details(transfer-id)`: 🆕 Get details of a specific transfer

#### Fractionalization Information
- `get-fraction-details(credit-id)`: Get fractionalization metadata (original credit, fraction number, total fractions)
- `is-fractional-credit(credit-id)`: Check if credit is a fractional unit
- `get-min-fraction-amount()`: Get minimum amount per fraction (returns 1)

#### IoT & Sensor Information
- `get-sensor-details(sensor-id)`: Get IoT sensor information and status
- `get-sensor-reading(sensor-id, timestamp)`: Get sensor reading data for specific timestamp
- `is-oracle-authorized(oracle)`: Check oracle authorization status

#### Platform Information
- `get-platform-fee()`: Current platform fee (in basis points)
- `get-next-credit-id()`: Next available credit ID
- `get-next-sensor-id()`: Next available sensor ID
- `get-max-batch-size()`: Maximum allowed batch size (50)
- `get-next-transfer-id()`: 🆕 Next transfer ID

## Data Structures

### Carbon Credit Structure
```clarity
{
  issuer: principal,              // Credit issuer
  owner: principal,               // Current owner  
  amount: uint,                   // Number of credits
  price-per-credit: uint,         // Price in microSTX
  project-type: string,           // e.g. "Solar Farm"
  verification-standard: string,  // e.g. "VCS", "Gold Standard"
  issue-date: uint,               // Block height when issued
  retired: bool,                  // Retirement status
  for-sale: bool,                 // Marketplace status
  sensor-id: optional uint,       // Linked IoT sensor
  verification-status: string,    // "pending" or "verified"
  last-verified: optional uint,   // Last verification block
  parent-credit-id: optional uint, // Original credit (for fractions)
  is-fractional: bool             // Whether this is a fractional credit
}
```

### Transfer Record Structure 🆕
```clarity
{
  from: principal,          // Sender address
  to: principal,            // Recipient address
  credit-id: uint,          // Transferred credit ID
  amount: uint,             // Credit amount
  transfer-date: uint       // Block height of transfer
}
```

## 📊 Use Cases

### 1. Direct Gift/Donation
```clarity
;; Gift credits to environmental organization
(transfer-credit u5 'ST1ENVIRONMENTAL-ORG...)
;; Zero fees, instant transfer with proof
```

### 2. Corporate Distribution
```clarity
;; Company distributes credits to employees
(transfer-credit u10 'ST1EMPLOYEE1...)
(transfer-credit u11 'ST1EMPLOYEE2...)
;; Track all distributions via transfer history
```

### 3. Fractionalization + Transfer
```clarity
;; Split large credit and gift fractions
(fractionalize-credit u1 u10)
(transfer-credit u2 'ST1FRIEND...)  ;; Gift one fraction
(transfer-credit u3 'ST1CHARITY...) ;; Donate another
;; Keep remaining fractions
```

## Usage Examples

### Direct Transfer Workflow 🆕

```clarity
;; Issue credits
(contract-call? .greenreward issue-credits u500 u50000000 "Solar Farm" "VCS" none)
;; Returns: (ok u1)

;; Transfer 500 units to another user
(contract-call? .greenreward transfer-credit u1 'ST1RECIPIENT...)
;; Returns: (ok u1) - transfer ID

;; Check transfer details
(contract-call? .greenreward get-transfer-details u1)
;; Returns transfer record with from, to, amount, date
```

### Combined Workflows

```clarity
;; Split, transfer some, keep some, sell some
(fractionalize-credit u1 u5)       ;; Split into 5 fractions
(transfer-credit u2 'ST1FRIEND...) ;; Gift one fraction
(list-for-sale u3 u52000000)       ;; Sell one fraction
;; Keep u4, u5, u6 for later
```

## Error Codes

| Code | Error | Description |
|------|-------|-------------|
| `u100` | Unauthorized access | User lacks required permissions |
| `u101` | Invalid amount | Amount must be greater than 0 |
| `u102` | Insufficient balance | Not enough credits available |
| `u103` | Credit not found | Credit ID does not exist |
| `u104` | Credit already retired | Cannot operate on retired credit |
| `u105` | Invalid price | Price must be greater than 0 |
| `u106` | Self-trade attempt | Cannot purchase own credits |
| `u107` | Invalid string input | String validation failed |
| `u108` | Empty batch operation | Batch cannot be empty |
| `u109` | Batch size too large | Exceeds maximum batch size (50) |
| `u110` | IoT sensor not found | Sensor ID does not exist or inactive |
| `u111` | Invalid sensor data | Sensor reading validation failed |
| `u112` | Verification threshold not met | Sensor data below required threshold |
| `u113` | Sensor already registered | Sensor address already in use |
| `u114` | Invalid oracle | Oracle not authorized or invalid |
| `u115` | Arithmetic overflow | Mathematical operation overflow |
| `u116` | Invalid principal | Principal validation failed |
| `u117` | Invalid fraction | Fractionalization parameters invalid |
| `u118` | Credit cannot be split | Credit is ineligible for fractionalization |
| `u119` | Self-transfer | 🆕 Cannot transfer to yourself |
| `u120` | Credit listed for sale | 🆕 Cannot transfer listed credits |

## Platform Economics

### Fee Structure
- **Platform Fee**: Maximum 10% (1000 basis points), configurable by admin
- **Default Fee**: 2.5% (250 basis points)
- **Fee Distribution**: Platform fees go to contract owner for platform sustainability
- **Transaction Costs**: Standard Stacks blockchain fees apply
- **Transfer Fees**: 🆕 ZERO fees on direct transfers (only gas costs)

### Transfer Economics 🆕
- **No Platform Fee**: Direct transfers are completely free
- **Gas Only**: Users only pay blockchain transaction costs
- **Corporate Savings**: Bulk transfers save on marketplace fees
- **Charitable Deductions**: Clear proof of donation value

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for transactions
- IoT sensors (optional) for automated verification
- Oracle authorization for sensor data submission

### Installation

1. Clone the repository
```bash
git clone https://github.com/your-org/greenreward
cd greenreward
```

2. Install dependencies and check contract
```bash
clarinet check
```

3. Run tests
```bash
clarinet test
```

4. Deploy contract
```bash
clarinet deploy
```

## Security Features

### Smart Contract Security
- **Safe Arithmetic**: All mathematical operations include overflow protection
- **Input Validation**: Comprehensive validation of all user inputs
- **Access Control**: Role-based permissions for sensitive operations
- **Principal Validation**: Protection against invalid principal addresses
- **Bounds Checking**: Validation of all numeric inputs and limits
- **Fractionalization Safeguards**: Prevents splitting listed or retired credits
- **🆕 Transfer Safeguards**: Prevents self-transfers and transfers of listed credits

### Data Integrity
- **Oracle Authorization**: Only authorized oracles can submit sensor data
- **Sensor Validation**: Comprehensive sensor registration and validation
- **Timestamp Verification**: All sensor readings include block timestamps
- **Immutable Records**: All data permanently stored on blockchain
- **Fraction Tracking**: Parent-child relationships preserved for audit trail
- **🆕 Transfer Audit Trail**: Complete history of all credit movements

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**GreenReward** - Making carbon credits transparent, verifiable, and accessible through blockchain, IoT technology, flexible fractionalization, and direct peer-to-peer transfers. 🌍