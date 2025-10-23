# GreenReward 🌱

A decentralized carbon credit marketplace built on Stacks blockchain, enabling transparent trading and retirement of verified carbon credits with **automated IoT sensor verification** and **flexible credit fractionalization**.

## Overview

GreenReward facilitates the creation, trading, and retirement of carbon credits through smart contracts, providing transparency and efficiency to the carbon offset market. Users can issue credits for environmental projects, trade them on the marketplace, and retire them to offset their carbon footprint. **NEW**: Real-time environmental data validation through IoT sensor integration ensures project authenticity and impact measurement. **LATEST**: Credit fractionalization enables splitting and merging of carbon credits for flexible portfolio management.

## Features

- **Credit Issuance**: Create carbon credits with verified environmental projects
- **🆕 Credit Fractionalization**: Split credits into smaller denominations (2-50 fractions) or merge fractional credits
- **🆕 Flexible Trading**: Trade whole credits or fractional units for better liquidity
- **IoT Sensor Integration**: Real-time environmental monitoring and automated verification
- **Oracle Network**: Authorized data oracles for sensor reading validation  
- **Batch Operations**: Efficient bulk issuance and retirement of multiple credits
- **Marketplace Trading**: Buy and sell credits with transparent pricing
- **Credit Retirement**: Permanently retire credits for carbon offsetting
- **User Balances**: Track owned and retired credits
- **Platform Fees**: Built-in fee structure for platform sustainability (max 10%)
- **Verification Status**: Track credit verification through IoT data
- **Safe Arithmetic**: Overflow protection for all mathematical operations

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
- **Strategic Trading**: Hold some fractions while selling others

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

### Fractionalization Process

#### Split Credits
```clarity
;; Split a 100-unit credit into 4 fractions
(contract-call? .greenreward fractionalize-credit u1 u4)
;; Returns: {original-credit-id: u1, fraction-ids: (list u10 u11 u12 u13), total-fractions: u4}
;; Fractions: 25, 25, 25, 25 units (evenly distributed)
```

#### Merge Fractional Credits
```clarity
;; Merge 3 fractional credits back together
(contract-call? .greenreward merge-fractional-credits (list u10 u11 u12))
;; Returns: u20 (new merged credit ID with 75 total units)
```

## IoT Sensor Integration 🔗

### Automated Verification System
GreenReward integrates with IoT sensors to provide real-time environmental data verification:

- **Sensor Registration**: Register environmental monitoring devices for projects
- **Real-time Data**: Continuous monitoring of CO2 reduction, energy generation, and tree planting
- **Automated Verification**: Credits automatically verified when sensor thresholds are met
- **Oracle Network**: Trusted data oracles submit verified sensor readings
- **Transparency**: All sensor data and verifications are recorded on-chain
- **Sensor Management**: Admin controls for sensor activation/deactivation

### Supported Sensor Types
- **Solar Power Meters**: Energy generation monitoring
- **CO2 Sensors**: Carbon dioxide reduction measurement  
- **Environmental Monitors**: Tree planting and ecosystem impact tracking
- **Wind Power Sensors**: Renewable energy output verification
- **Custom Sensors**: Support for various environmental monitoring devices

### Verification Process
1. **Sensor Registration**: Project owners register IoT sensors with verification thresholds
2. **Data Collection**: Sensors continuously monitor environmental metrics (CO2 reduction, energy generation, trees planted)
3. **Oracle Submission**: Authorized oracles submit verified sensor readings with timestamps
4. **Automatic Verification**: Credits verified when combined sensor data meets thresholds
5. **Status Update**: Credit verification status updated from "pending" to "verified" on-chain

## Smart Contract Functions

### Credit Management

#### Individual Operations
- `issue-credits(amount, price, project-type, verification-standard, sensor-id)`: Issue new carbon credits with optional IoT sensor integration
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

#### Fractionalization Information 🆕
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
  parent-credit-id: optional uint, // 🆕 Original credit (for fractions)
  is-fractional: bool             // 🆕 Whether this is a fractional credit
}
```

### Credit Fraction Structure 🆕
```clarity
{
  original-credit-id: uint,  // ID of the original credit that was split
  fraction-number: uint,     // Which fraction this is (1, 2, 3, etc.)
  total-fractions: uint      // Total number of fractions created
}
```

### IoT Sensor Structure
```clarity
{
  sensor-address: string,         // Unique sensor identifier
  project-location: string,       // Physical location
  sensor-type: string,            // Type of sensor
  registered-by: principal,       // Registering user
  registration-date: uint,        // Registration block
  is-active: bool,               // Sensor status
  last-reading: optional uint,   // Last reading block
  verification-threshold: uint   // Minimum threshold for verification
}
```

### Sensor Reading Structure
```clarity
{
  co2-reduction: uint,        // CO2 reduced (in units)
  energy-generated: uint,     // Energy generated (in units)
  trees-planted: uint,        // Trees planted count
  verified: bool,             // Reading verification status
  oracle: principal          // Submitting oracle
}
```

## 📊 Use Cases

### 1. Large Credit Holder
```clarity
;; Have 10,000 units, want to sell portions
(fractionalize-credit u1 u10)  ;; Create 10x1,000 unit fractions
(list-for-sale u2 u55000000)   ;; Sell some
;; Keep others as long-term holdings
```

### 2. Small Investor
```clarity
;; Buy affordable fractional credits
(purchase-credits u15 u100)  ;; Buy 100-unit fraction
;; More accessible than 10,000-unit credit
```

### 3. Portfolio Manager
```clarity
;; Collect fractions, merge for efficiency
(purchase-credits u20 u50)
(purchase-credits u21 u50)
(purchase-credits u22 u50)
(merge-fractional-credits (list u20 u21 u22))  ;; Create 150-unit credit
```

## 🔧 Technical Implementation

### Fractionalization Algorithm
The fractionalization function uses an efficient fold-based approach:
- Generates indices for the requested number of fractions (2-50)
- Calculates base amount per fraction with remainder distribution
- First fraction receives any remainder to ensure exact total
- Uses `fold` to create all fractions in a single pass
- No recursion - fully compatible with Clarity constraints

### Example: Splitting 1000 units into 3 fractions
```
Total: 1000 units
Fractions requested: 3
Base amount: 1000 / 3 = 333
Remainder: 1000 % 3 = 1

Result:
- Fraction 1: 333 + 1 = 334 units
- Fraction 2: 333 units  
- Fraction 3: 333 units
Total: 1000 units (verified)
```

---

## Usage Examples

### Fractionalization Workflow 🆕

#### Splitting Credits
```clarity
;; Issue a large credit
(contract-call? .greenreward issue-credits u1000 u50000000 "Solar Farm" "VCS" none)
;; Returns: (ok u1)

;; Split into 10 fractions of 100 units each
(contract-call? .greenreward fractionalize-credit u1 u10)
;; Returns: (ok {original-credit-id: u1, fraction-ids: (list u2 u3 u4 u5 u6 u7 u8 u9 u10 u11), total-fractions: u10})

;; Each fraction can now be traded independently
(contract-call? .greenreward list-for-sale u2 u52000000) ;; List first fraction
(contract-call? .greenreward list-for-sale u3 u51000000) ;; List second fraction at different price
```

#### Merging Fractional Credits
```clarity
;; Purchase multiple fractional credits from marketplace
(contract-call? .greenreward purchase-credits u5 u100)
(contract-call? .greenreward purchase-credits u6 u100)
(contract-call? .greenreward purchase-credits u7 u100)

;; Merge them into a single larger credit
(contract-call? .greenreward merge-fractional-credits (list u5 u6 u7))
;; Returns: (ok u20) - new merged credit with 300 units
```

### Basic Credit Operations
```clarity
;; Issue credits without IoT sensor
(contract-call? .greenreward issue-credits u100 u50000000 "Solar Farm" "VCS" none)

;; List credits for sale
(contract-call? .greenreward list-for-sale u1 u55000000)

;; Purchase credits
(contract-call? .greenreward purchase-credits u1 u50)

;; Retire credits for offsetting
(contract-call? .greenreward retire-credits u1)
```

### IoT Integration Workflow
```clarity
;; 1. Register IoT sensor
(contract-call? .greenreward register-iot-sensor 
  "ENV-SENSOR-001" 
  "Wind Farm, Texas" 
  "Wind Power Meter" 
  u1500)

;; 2. Issue credits with sensor
(contract-call? .greenreward issue-credits 
  u200 u60000000 "Wind Power" "Gold Standard" (some u1))

;; 3. Oracle submits sensor data
(contract-call? .greenreward submit-sensor-reading u1 u800 u1200 u0)

;; 4. Verify credits with sensor data
(contract-call? .greenreward verify-credits-with-sensor u1)
```

### Oracle Management (Admin Only)
```clarity
;; Authorize new oracle
(contract-call? .greenreward authorize-oracle 'ST1ORACLE...)

;; Revoke oracle authorization  
(contract-call? .greenreward revoke-oracle 'ST1ORACLE...)

;; Update platform fee to 3%
(contract-call? .greenreward update-platform-fee u300)
```

## Integration Guide

### Frontend Integration

#### 1. Install Dependencies
```bash
npm install @stacks/connect @stacks/transactions @stacks/network
```

#### 2. Contract Calls Example
```javascript
import { openContractCall } from '@stacks/connect';
import { uintCV, listCV, PostConditionMode } from '@stacks/transactions';

// Fractionalize a credit
const fractionalizeCredit = async (creditId, numFractions) => {
  await openContractCall({
    contractAddress: 'ST1...',
    contractName: 'greenreward',
    functionName: 'fractionalize-credit',
    functionArgs: [uintCV(creditId), uintCV(numFractions)],
    postConditionMode: PostConditionMode.Deny,
    onFinish: (data) => {
      console.log('Fractionalization complete:', data);
    },
  });
};

// Merge fractional credits
const mergeFractionalCredits = async (fractionIds) => {
  await openContractCall({
    contractAddress: 'ST1...',
    contractName: 'greenreward',
    functionName: 'merge-fractional-credits',
    functionArgs: [listCV(fractionIds.map(id => uintCV(id)))],
    postConditionMode: PostConditionMode.Deny,
    onFinish: (data) => {
      console.log('Merge complete:', data);
    },
  });
};
```

#### 3. Add UI Component
Copy the provided React component (`CreditFractionalization.jsx`) into your project:
```
src/
  components/
    CreditFractionalization.jsx  // Fractionalization UI
    Dashboard.jsx                 // Main dashboard
    Marketplace.jsx              // Trading interface
```

Import and use in your app:
```javascript
import CreditFractionalization from './components/CreditFractionalization';

function App() {
  return (
    <div>
      {/* Other components */}
      <CreditFractionalization />
    </div>
  );
}
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
| `u117` | Invalid fraction | 🆕 Fractionalization parameters invalid |
| `u118` | Credit cannot be split | 🆕 Credit is ineligible for fractionalization |

## Platform Economics

### Fee Structure
- **Platform Fee**: Maximum 10% (1000 basis points), configurable by admin
- **Default Fee**: 2.5% (250 basis points)
- **Fee Distribution**: Platform fees go to contract owner for platform sustainability
- **Transaction Costs**: Standard Stacks blockchain fees apply

### Fractionalization Economics 🆕
- **No Fractionalization Fee**: Splitting and merging are free (only gas costs)
- **Fractional Trading**: Same platform fees apply to fractional credit trades
- **Market Impact**: Increased liquidity from fractionalization may improve price discovery
- **Volume Benefits**: Higher trading volumes from fractional units increase platform revenue

### Marketplace Dynamics
- **Price Discovery**: Open market pricing for carbon credits
- **Quality Premium**: IoT-verified credits typically command higher prices
- **Fractional Premium**: Smaller denominations may trade at slight premiums due to accessibility
- **Automated Trading**: Smart contract handles all transfers and fee collection
- **No Self-Trading**: Users cannot purchase their own credits

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

## Testing

### Run Test Suite
```bash
clarinet test
```

### Test Coverage
- Credit issuance and management
- ✅ Credit fractionalization (split and merge)
- ✅ Fractional credit validation
- IoT sensor registration and data submission
- Batch operations functionality
- Oracle authorization and management
- Marketplace trading and fee collection
- Error handling and edge cases
- Security and validation functions

### Integration Testing
```bash
clarinet console
```

Test fractionalization features in interactive console:
```clarity
;; Issue a credit
(contract-call? .greenreward issue-credits u1000 u50000000 "Solar Farm" "VCS" none)

;; Fractionalize it
(contract-call? .greenreward fractionalize-credit u1 u5)

;; Check fraction details
(contract-call? .greenreward get-fraction-details u2)
(contract-call? .greenreward is-fractional-credit u2)
```

## Security Features

### Smart Contract Security
- **Safe Arithmetic**: All mathematical operations include overflow protection
- **Input Validation**: Comprehensive validation of all user inputs
- **Access Control**: Role-based permissions for sensitive operations
- **Principal Validation**: Protection against invalid principal addresses
- **Bounds Checking**: Validation of all numeric inputs and limits
- **🆕 Fractionalization Safeguards**: Prevents splitting listed or retired credits

### Data Integrity
- **Oracle Authorization**: Only authorized oracles can submit sensor data
- **Sensor Validation**: Comprehensive sensor registration and validation
- **Timestamp Verification**: All sensor readings include block timestamps
- **Immutable Records**: All data permanently stored on blockchain
- **🆕 Fraction Tracking**: Parent-child relationships preserved for audit trail

### Economic Security
- **Platform Fee Limits**: Maximum 10% platform fee cap
- **Self-Trade Prevention**: Users cannot purchase their own credits
- **Marketplace Controls**: Automated listing and delisting protections
- **🆕 Fraction Limits**: Maximum 50 fractions per credit prevents spam

## Contributing

### Development Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/credit-fractionalization`)
3. Write comprehensive tests for new functionality
4. Ensure all tests pass (`clarinet test`)
5. Submit a pull request with detailed description

### Coding Standards
- Follow Clarity best practices
- Include comprehensive error handling
- Add inline documentation for complex functions
- Maintain backward compatibility
- Include test coverage for new features

### Development Roadmap
- [x] Credit fractionalization functionality
- [ ] Advanced fractionalization analytics dashboard
- [ ] Automated fraction rebalancing
- [ ] Fractional credit bundles (ETF-style)
- [ ] Machine learning-based fraud detection for sensor data
- [ ] Mobile app for sensor management and monitoring
- [ ] Integration with additional IoT sensor types
- [ ] Cross-chain oracle integration for expanded data sources
- [ ] Carbon footprint calculator integration
- [ ] Corporate dashboard for bulk operations
- [ ] API gateway for third-party integrations

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support & Community

### Technical Support
- **GitHub Issues**: Report bugs and request features
- **Documentation**: Comprehensive guides and examples
- **Code Examples**: Sample implementations and integration patterns

### Community Resources
- **Discord Server**: Join our developer community
- **Newsletter**: Stay updated on platform developments
- **Blog**: Technical articles and case studies

### Contact Information
- **Email**: support@greenreward.io
- **Twitter**: @GreenRewardDeFi
- **GitHub**: github.com/greenreward/platform

---

**GreenReward** - Making carbon credits transparent, verifiable, and accessible through blockchain, IoT technology, and flexible fractionalization. 🌍
