# No-Loss Cross-Chain Raffle

A decentralized, multi-chain raffle system where **nobody loses their principal**. Player deposits are routed into Aave lending pools to generate yield — the winner takes the interest, not the deposits. Built with Solidity and the Foundry framework, leveraging Chainlink's oracle ecosystem for verifiable randomness, price feeds, automation, and cross-chain interoperability.

> **TL;DR** — Users buy tickets with stablecoins, funds earn yield on Aave, a provably fair winner is selected via Chainlink VRF, and players on *any* supported chain can participate through Chainlink CCIP.

---

## Architecture

```
                        Satellite Chain(s)
                       ┌──────────────────┐
                       │   SenderCCIP.sol  │  ← Users enter raffle here
                       └────────┬─────────┘
                                │  Chainlink CCIP
                                ▼
Main Chain  ┌───────────────────────────────────────────┐
            │              ReceiverCCIP.sol              │
            │   ┌─────────────────────────────────┐     │
            │   │        NoLossRaffle.sol          │     │
            │   │  ┌───────────┐  ┌────────────┐  │     │
            │   │  │ Aave Pool │  │Chainlink VRF│  │     │
            │   │  └───────────┘  └────────────┘  │     │
            │   │        ┌────────────┐           │     │
            │   │        │ Automation │           │     │
            │   │        └────────────┘           │     │
            │   └─────────────────────────────────┘     │
            └───────────────────────────────────────────┘
```

---

## Key Features

| Feature | Description |
|---|---|
| **No-Loss Model** | Player deposits are supplied to Aave; only the generated yield is distributed as prizes. Principal is always recoverable. |
| **Cross-Chain Participation** | Chainlink CCIP enables users on satellite chains to enter the raffle without bridging funds manually. |
| **Provably Fair Randomness** | Winner selection uses Chainlink VRF v2.5 — on-chain verifiable, tamper-proof randomness. |
| **Automated Round Management** | Chainlink Automation triggers round transitions (closing entries, selecting winners) without manual intervention. |
| **Dynamic Pricing** | Ticket prices are set in USD and converted to ETH in real-time using Chainlink Price Feeds. |
| **Multi-Round System** | Configurable maximum rounds with per-round player tracking and ticket counts. |
| **Pause / Resume** | Owner can pause and resume the raffle with remaining time preservation. |

---

## Tech Stack

- **Solidity** — Smart contract language
- **Foundry** (Forge, Cast, Anvil) — Development, testing, and deployment framework
- **Chainlink VRF v2.5** — Verifiable random function for fair winner selection
- **Chainlink CCIP** — Cross-chain messaging between satellite and main chains
- **Chainlink Automation** — Trustless, time-based round management
- **Chainlink Price Feeds** — Real-time ETH/USD conversion
- **Aave v3** — Yield generation via lending pool deposits
- **OpenZeppelin** — Access control (`Ownable`)
- **Solmate** — Gas-optimized ERC20 implementation

---

## Contracts Overview

| Contract | Purpose |
|---|---|
| [NoLossRaffle.sol](src/NoLossRaffle.sol) | Core raffle logic — ticket sales, Aave deposits, VRF winner selection, yield distribution (95% winner / 5% host) |
| [Raffle.sol](src/Raffle.sol) | Original ETH-based raffle with direct prize pool distribution |
| [ReceiverCCIP.sol](src/ReceiverCCIP.sol) | Main-chain receiver — processes cross-chain entries and sends status updates back to satellites |
| [SenderCCIP.sol](src/SenderCCIP.sol) | Satellite-chain sender — encodes and forwards raffle entries via CCIP |
| [PriceConverter.sol](src/PriceConverter.sol) | Library for ETH/USD conversions using Chainlink Price Feeds |
| [HelperConfig.s.sol](script/HelperConfig.s.sol) | Multi-chain deployment configuration (Mainnet, Sepolia, Anvil) |
| [DeployRaffleScript.s.sol](script/DeployRaffleScript.s.sol) | Automated deployment — creates VRF subscriptions, funds with LINK, registers consumers |

---

## How It Works

```
1. HOST creates a raffle         →  configures ticket price, round duration, max rounds
2. PLAYERS buy tickets           →  stablecoins transferred to raffle contract
3. Round closes (Automation)     →  entries locked, funds supplied to Aave
4. Yield accrues                 →  Aave generates interest on deposited funds
5. Winner selected (VRF)         →  Chainlink VRF picks a verifiably random winner
6. Yield distributed             →  95% to winner, 5% to host
7. Principal returned            →  all players get their deposits back
```

---

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- An RPC endpoint (Alchemy, Infura, etc.)

### Build & Test

```bash
make build          # Compile contracts
make test           # Run unit tests
make snapshot       # Generate gas snapshots
make format         # Format Solidity code
```

### Deploy

```bash
# Local (Anvil)
make anvil          # Start local node in a separate terminal
make deploy-anvil

# Sepolia Testnet
make deploy-sepolia
```

### Manual Forge Commands

```bash
forge build
forge test
forge script script/DeployRaffleScript.s.sol:DeployRaffleScript --rpc-url <RPC_URL> --private-key <PRIVATE_KEY> --broadcast
```

---

## Project Structure

```
├── src/
│   ├── NoLossRaffle.sol        # Core raffle with Aave yield generation
│   ├── Raffle.sol              # Original ETH-based raffle
│   ├── SenderCCIP.sol          # Cross-chain entry sender (satellite)
│   ├── ReceiverCCIP.sol        # Cross-chain entry receiver (main)
│   ├── PriceConverter.sol      # Chainlink price feed library
│   └── interfaces/
│       ├── IRaffle.sol
│       ├── IReceiverCCIP.sol
│       └── IPool.sol           # Aave pool interface
├── script/
│   ├── DeployRaffleScript.s.sol
│   ├── HelperConfig.s.sol      # Multi-chain config
│   └── Interactions.s.sol      # VRF subscription helpers
├── test/
│   ├── unit/raffle.t.sol
│   └── mocks/
├── Makefile
└── foundry.toml
```

---

## Design Decisions

- **Yield-based prizes over direct pools** — Eliminates financial risk for participants, making the raffle accessible to risk-averse users.
- **Chainlink VRF v2.5 over block hash** — Block hash randomness is manipulable by miners/validators; VRF provides cryptographic guarantees.
- **CCIP over custom bridges** — Standardized, audited cross-chain messaging reduces attack surface vs. rolling a custom bridge.
- **State machine pattern** — `RaffleStatut` enum enforces valid state transitions, preventing re-entrancy and race conditions.
- **Allowlist for cross-chain senders** — Only whitelisted satellite contracts can submit entries, preventing unauthorized cross-chain calls.

---

## Future Improvements

- [ ] Integration tests for cross-chain flows using CCIP local simulator
- [ ] Fuzz and invariant testing for edge cases
- [ ] Frontend (React + wagmi/viem) for user interaction
- [ ] Support for multiple stablecoin ticket types (USDT, DAI)
- [ ] Governance module for decentralized raffle parameter updates

---

## License

MIT
