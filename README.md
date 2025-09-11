# GreenReward 🌱

A decentralized carbon credit marketplace built on Stacks blockchain, enabling transparent trading and retirement of verified carbon credits with **automated IoT sensor verification**.

## Overview

GreenReward facilitates the creation, trading, and retirement of carbon credits through smart contracts, providing transparency and efficiency to the carbon offset market. Users can issue credits for environmental projects, trade them on the marketplace, and retire them to offset their carbon footprint. **NEW**: Real-time environmental data validation through IoT sensor integration ensures project authenticity and impact measurement.

## Features

- **Credit Issuance**: Create carbon credits with verified environmental projects
- **🆕 IoT Sensor Integration**: Real-time environmental monitoring and automated verification
- **🆕 Oracle Network**: Authorized data oracles for sensor reading validation  
- **Batch Operations**: Efficient bulk issuance and retirement of multiple credits
- **Marketplace Trading**: Buy and sell credits with transparent pricing
- **Credit Retirement**: Permanently retire credits for carbon offsetting
- **User Balances**: Track owned and retired credits
- **Platform Fees**: Built-in fee structure for platform sustainability (max 10%)
- **🆕 Verification Status**: Track credit verification through IoT data
- **🆕 Safe Arithmetic**: Overflow protection for all mathematical operations

## IoT Sensor Integration 🔗

### Automated Verification System
GreenReward now integrates with IoT sensors to provide real-time environmental data verification:

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

### IoT Integration Functions 🆕

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

#### IoT & Sensor Information 🆕
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
  issuer: principal,           // Credit issuer
  owner: principal,            // Current owner  
  amount: uint,               // Number of credits
  price-per-credit: uint,     // Price in microSTX
  project-type: string,       // e.g. "Solar Farm"
  verification-standard: string, // e.g. "VCS", "Gold Standard"
  issue-date: uint,           // Block height when issued
  retired: bool,              // Retirement status
  for-sale: bool,            // Marketplace status
  sensor-id: optional uint,   // Linked IoT sensor
  verification-status: string, // "pending" or "verified"
  last-verified: optional uint // Last verification block
}
```

### IoT Sensor Structure
```clarity
{
  sensor-address: string,      // Unique sensor identifier
  project-location: string,    // Physical location
  sensor-type: string,         // Type of sensor
  registered-by: principal,    // Registering user
  registration-date: uint,     // Registration block
  is-active: bool,            // Sensor status
  last-reading: optional uint, // Last reading block
  verification-threshold: uint // Minimum threshold for verification
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

## IoT Sensor Operations 🚀

### Registering IoT Sensors

Connect environmental monitoring devices to your carbon projects:

```clarity
(register-iot-sensor 
  "SOLAR-METER-12345" 
  "Solar Farm Project, California, USA" 
  "Solar Power Meter" 
  u1000) ;; Verification threshold (combined sensor readings must exceed this)
```

### Batch Credit Issuance with IoT

Issue credits with linked IoT sensors for automated verification:

```clarity
(batch-issue-credits 
  (list 
    {
      amount: u100, 
      price: u50000000, ;; 50 STX per credit in microSTX
      project-type: "Solar Farm", 
      verification-standard: "VCS", 
      sensor-id: (some u1)
    }
    {
      amount: u200, 
      price: u45000000, 
      project-type: "Wind Power", 
      verification-standard: "Gold Standard", 
      sensor-id: (some u2)
    }
  )
)
```

### Oracle Data Submission

Authorized oracles submit verified environmental data:

```clarity
(submit-sensor-reading 
  u1          ;; sensor-id
  u500        ;; co2-reduction (tons)
  u2000       ;; energy-generated (kWh)
  u50)        ;; trees-planted (count)
```

### Credit Verification Process

Verify credits using IoT sensor data when thresholds are met:

```clarity
(verify-credits-with-sensor u1) ;; credit-id
;; Verification succeeds when: co2-reduction + energy-generated + trees-planted >= verification-threshold
```

## Batch Operations

### Batch Credit Issuance

Issue multiple carbon credits in a single transaction for improved efficiency:

```clarity
(batch-issue-credits 
  (list 
    {
      amount: u100, 
      price: u50000000, 
      project-type: "Solar Farm", 
      verification-standard: "VCS", 
      sensor-id: none
    }
    {
      amount: u200, 
      price: u45000000, 
      project-type: "Reforestation", 
      verification-standard: "Gold Standard", 
      sensor-id: (some u1)
    }
  )
)
```

**Benefits:**
- Reduced transaction costs
- Improved efficiency for large-scale projects  
- Atomic operations (all succeed or all fail)
- Maximum batch size: 50 credits per transaction
- **🆕 IoT sensor integration support**
- **🆕 Safe arithmetic prevents overflow**

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
- Automatic marketplace removal

## Platform Economics

### Fee Structure
- **Platform Fee**: Maximum 10% (1000 basis points), configurable by admin
- **Default Fee**: 2.5% (250 basis points)
- **Fee Distribution**: Platform fees go to contract owner for platform sustainability
- **Transaction Costs**: Standard Stacks blockchain fees apply

### Marketplace Dynamics
- **Price Discovery**: Open market pricing for carbon credits
- **Quality Premium**: IoT-verified credits typically command higher prices
- **Automated Trading**: Smart contract handles all transfers and fee collection
- **No Self-Trading**: Users cannot purchase their own credits

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks wallet for transactions
- **🆕 IoT sensors (optional)** for automated verification
- **🆕 Oracle authorization** for sensor data submission

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

### Usage Examples

#### Basic Credit Operations
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

#### IoT Integration Workflow
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

#### Oracle Management (Admin Only)
```clarity
;; Authorize new oracle
(contract-call? .greenreward authorize-oracle 'ST1ORACLE...)

;; Revoke oracle authorization  
(contract-call? .greenreward revoke-oracle 'ST1ORACLE...)

;; Update platform fee to 3%
(contract-call? .greenreward update-platform-fee u300)
```

### Error Codes

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

## IoT Verification Benefits

### For Project Owners
- **Automated Verification**: No manual verification delays
- **Real-time Monitoring**: Continuous project performance tracking  
- **Enhanced Credibility**: Tamper-proof environmental data
- **Premium Pricing**: Verified credits command higher market prices
- **Reduced Costs**: Automated verification reduces operational overhead

### For Buyers
- **Transparency**: Real-time access to project performance data
- **Assurance**: IoT-verified environmental impact with timestamps
- **Trust**: Blockchain-recorded sensor data prevents fraud
- **Quality**: Purchase only verified, high-impact credits
- **Compliance**: Meet sustainability reporting requirements

### For the Market
- **Efficiency**: Automated verification reduces processing time
- **Standards**: Consistent, technology-driven verification standards
- **Scalability**: Support for large-scale environmental projects
- **Innovation**: Cutting-edge approach to carbon credit markets
- **Integrity**: Oracle network ensures data accuracy

## Oracle Network

### Authorized Oracles
The platform maintains a network of authorized oracles responsible for:
- Validating sensor data integrity and authenticity
- Submitting verified environmental readings with timestamps
- Ensuring data accuracy and timeliness  
- Maintaining sensor network reliability
- Following strict data submission protocols

### Oracle Requirements
- Technical expertise in IoT and environmental monitoring
- Commitment to data accuracy and integrity
- Regular sensor data submission schedule
- Compliance with platform verification standards
- Authorization by platform administrators

### Oracle Authorization Process
1. **Application**: Apply to become authorized oracle
2. **Verification**: Technical and credential verification
3. **Authorization**: Admin authorizes oracle principal
4. **Operation**: Submit sensor readings for verification
5. **Monitoring**: Ongoing performance monitoring

## Security Features

### Smart Contract Security
- **Safe Arithmetic**: All mathematical operations include overflow protection
- **Input Validation**: Comprehensive validation of all user inputs
- **Access Control**: Role-based permissions for sensitive operations
- **Principal Validation**: Protection against invalid principal addresses
- **Bounds Checking**: Validation of all numeric inputs and limits

### Data Integrity
- **Oracle Authorization**: Only authorized oracles can submit sensor data
- **Sensor Validation**: Comprehensive sensor registration and validation
- **Timestamp Verification**: All sensor readings include block timestamps
- **Immutable Records**: All data permanently stored on blockchain

### Economic Security
- **Platform Fee Limits**: Maximum 10% platform fee cap
- **Self-Trade Prevention**: Users cannot purchase their own credits
- **Marketplace Controls**: Automated listing and delisting protections

## Testing

### Run Test Suite
```bash
clarinet test
```

### Test Coverage
- Credit issuance and management
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

Test IoT integration features in interactive console.

## API Reference

### Contract Address
Deploy on Stacks mainnet or testnet for full functionality.

### Integration Libraries
Compatible with:
- Stacks.js for JavaScript/TypeScript applications
- Clarity SDK for native Clarity integration
- Web3 wallets (Hiro Wallet, Xverse)

## Contributing

### Development Process
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/sensor-integration`)
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
- [ ] Machine learning-based fraud detection for sensor data
- [ ] Mobile app for sensor management and monitoring
- [ ] Integration with additional IoT sensor types
- [ ] Advanced analytics dashboard for carbon tracking
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

**GreenReward** - Making carbon credits transparent, verifiable, and impactful through blockchain and IoT technology. 🌍

*Building the future of sustainable finance with automated verification and transparent trading.*