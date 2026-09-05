# UTTchain

<p align="center">
  <img src="images/banner.png" alt="UTTchain banner" width="100%" />
</p>

**UTTchain** is the Robinhood Chain protocol and infrastructure layer being developed for the **Unified Trading Terminal (UTT)** and **Unified Trading Terminal Token (UTTT)**.

> **Status — September 2026:** FOUNDATION / DESIGN. No UTTchain protocol deployment is live, no UTTT migration is authorized, and no existing UTTT deployment has yet been designated as the sole canonical supply.

## Overview

UTT is an existing local-first multi-venue trading terminal built with a React frontend and FastAPI backend. UTTchain is intended to extend that system into a secure, web-accessible, wallet-native architecture while using Robinhood Chain wherever blockchain execution provides a real trust, identity, settlement, or verification benefit.

UTTchain is **not** an attempt to run an entire trading terminal inside smart contracts. Smart contracts cannot directly run a browser UI, retain private centralized-exchange credentials, or make arbitrary authenticated HTTP requests to external exchanges. Those technical boundaries are treated explicitly rather than hidden behind a claim that every workload is on-chain.

### No-local-companion rule

**UTTchain production use must not require a second always-on local server, daemon, or companion machine.** Existing local UTT may remain available as an independent application and integration surface, but UTTchain's web/onchain functionality must not depend on the user starting another local service.

The architecture therefore follows this priority order:

1. **Robinhood Chain smart contracts and chain state** for deterministic protocol logic, identity, authorization, settlement, and state that benefits from public verification.
2. **Browser-side execution** for UI, wallet interaction, transaction construction, local ephemeral computation, and other work that can safely remain client-side.
3. **Replaceable public infrastructure** such as RPC providers, on-chain or cryptographically verified oracle inputs, and indexers where chain access or market-data delivery requires them.
4. **Hosted/serverless off-chain services only where technically unavoidable**, designed so they are not a user-operated local dependency and do not become hidden signing authorities.

For functions that cannot be performed safely or technically on-chain—especially authenticated CEX operations—the project will either keep them in the existing UTT application or design a secure web-accessible boundary later. A mandatory local UTTchain companion process is not an accepted production architecture.

Existing UTT repository: https://github.com/eyemaginative/utt-unified-trading-terminal

## Visual identity

The UTTchain visual system represents **many markets → one terminal → one protocol** through a shared network/routing motif. The banner, visual-identity composition, primary logo, and compact icon are maintained as canonical project artwork under `images/`.

### Visual identity

<p align="center">
  <img src="images/visual_identity.png" alt="UTTchain visual identity" width="760" />
</p>

### Primary logo

<p align="center">
  <img src="images/logo.png" alt="UTTchain primary logo" width="420" />
</p>

### Protocol icon

<p align="center">
  <img src="images/icon.png" alt="UTTchain protocol icon" width="280" />
</p>

Canonical artwork files:

```text
images/banner.png
images/visual_identity.png
images/logo.png
images/icon.png
```

## Architecture

```text
                         UTTchain Web
                         React / Vite
                              |
               +--------------+--------------+
               |              |              |
               v              v              v
        Browser Wallet      RPC /        Optional Hosted /
        / Smart Account     Indexer       Serverless Services*
               |              |              |
               +--------------+--------------+
                              |
                       ROBINHOOD CHAIN
                              |
                +-------------+-------------+
                |             |             |
               UTTT       Registry      Protocol
                                       Contracts

* Only where technically unavoidable; never a required user-run local daemon.
```

The long-term boundary is intentionally **onchain-first and no-local-companion**:

- **Web client:** browser-delivered React/Vite terminal. It must not require a localhost backend merely to use UTTchain's onchain features.
- **Wallet boundary:** browser wallet or future smart account authorizes blockchain transactions. UTTchain infrastructure does not silently become the user's signer.
- **Protocol boundary:** Robinhood Chain contracts carry protocol logic and state wherever EVM execution is technically suitable and economically reasonable.
- **Data boundary:** prefer on-chain state and cryptographically verifiable oracle inputs. RPC/indexer services are replaceable infrastructure rather than protocol authority.
- **Off-chain boundary:** hosted/serverless services may exist only for workloads that cannot reasonably execute in the EVM or browser. They must not impose a second user-operated local runtime.
- **CEX boundary:** CEX credentials remain off-chain. Smart contracts cannot directly authenticate to centralized-exchange HTTP APIs. CEX support therefore remains an application-layer capability and must not force UTTchain core users to run a local companion daemon.
- **Existing UTT:** local UTT can remain a supported integration client, but it is not a required runtime dependency for UTTchain's web/onchain protocol functions.

## Relationship to UTT

UTTchain does not replace UTT. It provides a protocol layer that UTT can consume while also supporting a browser-native UTTchain experience.

```text
                    ROBINHOOD CHAIN
                          UTTchain
                             |
             +---------------+---------------+
             |                               |
             v                               v
      UTTchain Web                     Existing UTT
     browser-native                   local application
             |                               |
      wallet/onchain                  broader off-chain
       interaction                    trading functions
             |                               |
             +---------------+---------------+
                             |
                    Shared protocol identity
```

The existing UTT codebase already contains Robinhood Chain functionality, including exact asset identity, registry-backed token handling, quote/execution context, browser-wallet transaction flows, receipt reconciliation, wallet-history ingestion, and order reconciliation. UTTchain gives that integration a separate protocol and security boundary while avoiding a requirement that web users operate additional local infrastructure.

## What belongs on-chain

Candidate responsibilities include:

- canonical UTTchain contract and deployment identities;
- UTTT identity and canonical-supply controls after multi-chain reconciliation;
- protocol configuration that benefits from public verifiability;
- exact chain/contract asset identity;
- wallet-authorized DEX settlement and related protocol actions;
- protocol accounting and state that is economically practical to maintain in the EVM;
- versioned capability declarations;
- selected cryptographic commitments to off-chain state;
- verification of signed oracle/data reports where applicable;
- future account-abstraction or governance components if justified.

## What cannot simply be moved on-chain

Some UTT workloads cannot be implemented solely as an EVM contract without changing their nature or security model:

- centralized-exchange API authentication and private API secrets;
- arbitrary authenticated HTTP requests to external services;
- a React/browser user interface;
- raw private portfolio and tax records that should not be globally public;
- high-volume relational queries and large application caches;
- unrestricted high-frequency market-data ingestion;
- general-purpose background computation that would be prohibitively expensive or impossible in the EVM.

Where such capabilities remain necessary, UTTchain will prefer browser execution, cryptographically verifiable data delivery, and replaceable hosted/serverless infrastructure. **Off-chain does not mean user-operated localhost.**

Private financial records should remain private unless a later protocol feature explicitly requires a privacy-preserving proof or commitment.

## UTTT: one canonical economic supply

UTTT already exists across multiple ecosystems, including:

- Robinhood Chain;
- Solana;
- the Polkadot ecosystem;
- Counterparty.

These assets are treated as **existing economic state that must be reconciled**, not disposable test deployments.

The design objective is:

```text
ONE UTTT
ONE ECONOMIC SUPPLY
MULTIPLE POSSIBLE EXECUTION DOMAINS
```

Before any deployment is declared canonical, the project will inventory each UTTT deployment or representation for identifier, issuer/deployer, current and historical supply, burns, holder distribution, treasury balances, liquidity, market pairs, bridge/migration history, and administrative authority.

Nominal supplies across chains will not simply be added together. Burned, escrowed, bridged, mirrored, or otherwise non-independent supply must be identified so economic UTTT is not double counted.

Potential future models include lock-and-mint representations, a canonical supply ledger spanning existing assets, deterministic holder migration, or a hybrid model preserving economically meaningful legacy markets. **No model is selected yet.** Existing holder interests and verifiable supply evidence come first.

## Planned protocol components

### UTTT

A reviewed existing deployment or a locally built canonical implementation, depending on the multi-chain forensic review. If a new Robinhood Chain implementation is required, the intended path is Solidity/OpenZeppelin/Foundry with unit, fuzz, invariant, static-analysis, testnet, and deployment-reconciliation gates.

### UTTchain Registry

A compact on-chain registry for identities that genuinely benefit from public authority, including canonical UTTchain component deployments, UTTT deployment identity, chain/contract identities, protocol versions, and capability declarations.

### Deployment manifests

Production-relevant deployments should produce machine-readable evidence including chain ID, address, deployment transaction, block, runtime identity/hash, compiler configuration, source commit, constructor arguments, and verification state.

### Browser-native protocol client

The primary UTTchain web client is intended to interact directly with Robinhood Chain through standard EVM wallet and RPC interfaces wherever feasible. It must not require a companion localhost server for core protocol use.

### Future account layer

ERC-4337 and related account-abstraction capabilities may later be evaluated for programmable wallets, batching, session keys, gas sponsorship, and bounded permissions. These are future capabilities, not current production claims.

### Future state commitments

UTT may eventually commit cryptographic roots of selected accounting/application states to Robinhood Chain without publishing the underlying private records.

## Security model

Standing security invariants:

- **No private keys or seed phrases in GitHub.**
- **No production exchange secrets in GitHub or frontend bundles.**
- **No CEX API credentials on-chain.**
- **No automatic blockchain signing by hosted UTTchain infrastructure.**
- **No mandatory user-operated local UTTchain server, daemon, or companion machine.**
- **No unlimited token approvals by default.**
- **No ticker/symbol-only asset authority.** Chain and contract identity matter.
- **No silent mainnet broadcasts.**
- **No automatic financial retry after transaction authority becomes uncertain.**
- **No undocumented privileged contract roles.**
- **No unreviewed proxy or upgrade authority.**
- **No public disclosure of private user financial records merely to make them on-chain.**
- **No production deployment from uncommitted or unreconciled source.**
- **No UTTT holder migration before supply and ownership reconciliation.**

Production security review will cover smart-contract behavior as well as browser security, wallet authorization, any unavoidable hosted-service boundaries, RPC/provider trust, oracle trust, privacy, and transaction reconciliation.

## Development-state vocabulary

```text
CONCEPT
SPECIFIED
IMPLEMENTED
TEST-GREEN
TESTNET DEPLOYED
MAINNET DEPLOYED
ACTIVATED
PRODUCTION ACCEPTED
```

A deployed contract does not by itself mean UTTchain is launched. A website being online does not by itself authorize production trading.

## Development lifecycle

```text
specification
    |
local implementation
    |
unit + fuzz + invariant testing
    |
static analysis
    |
fork / read-only integration
    |
Robinhood Chain testnet
    |
deployment reconciliation
    |
production security review
    |
explicit mainnet authorization
```

Local development tooling is used to build and test UTTchain; it is **not** a production runtime requirement for end users.

## Roadmap

### Foundation
- **UTTC.INIT** — repository, security baseline, README, public project announcement, Foundry bootstrap.
- **UTTC.0** — architecture, application/protocol boundary, no-local-companion invariant, trust boundaries, privacy model, threat model.

### UTTT canonicalization
- **UTTC.1** — forensic/supply intake for Robinhood Chain, Solana, Polkadot, and Counterparty UTTT.
- **UTTC.2** — one-canonical-supply and migration architecture.
- **UTTC.3** — canonical UTTT specification.
- **UTTC.4** — implementation and security testing if a replacement/new canonical contract is required.

### Protocol foundation
- **UTTC.5** — UTTchain Registry.
- **UTTC.6** — deployment-manifest standard.
- **UTTC.7** — Robinhood Chain testnet deployments and reconciliation.
- **UTTC.8** — UTT ↔ UTTchain integration adapter.

### Web architecture
- **UTTC.9** — browser-native/no-local-runtime web architecture.
- **UTTC.10** — off-chain persistence only where technically unavoidable; hosted/serverless rather than user-local.
- **UTTC.11** — authorization and isolation for any unavoidable hosted state.
- **UTTC.12** — CEX web/application boundary; no mandatory local UTTchain agent.
- **UTTC.13** — wallet-native authentication.
- **UTTC.14** — browser-wallet Robinhood Chain execution from the web terminal.
- **UTTC.15** — replaceable RPC/indexing/oracle infrastructure and direct on-chain reads where practical.

### Advanced protocol work
- **UTTC.16** — cryptographic accounting/state commitments.
- **UTTC.17** — ERC-4337/account abstraction.
- **UTTC.18** — evidence-driven UTTT utility design.
- **UTTC.19** — governance architecture if justified.

### Production
- **UTTC.20** — production security review.
- **UTTC.21** — mainnet deployment preflight.
- **UTTC.22** — explicitly authorized mainnet protocol deployment.
- **UTTC.23** — production web deployment with no mandatory local companion runtime.
- **UTTC.24** — end-to-end production acceptance.
- **UTTC.25** — post-launch operations and release/security management.

## Target repository structure

```text
UTTchain/
+-- README.md
+-- SECURITY.md
+-- CONTRIBUTING.md
+-- foundry.toml
+-- src/
+-- test/
+-- script/
+-- deployments/
+-- docs/
+-- abi/
+-- images/
```

The structure above is a target, not a claim that every component already exists.

## Current status

As of this foundation stage:

- UTTchain's Foundry project skeleton is established;
- the no-local-companion production rule is part of the architecture baseline;
- no UTTchain protocol contract is live;
- no UTTT migration is authorized;
- no existing UTTT deployment has been declared the sole canonical supply;
- no liquidity or market action is authorized by this repository;
- the existing UTT application remains a separate active project and reference implementation.

## License

A project license has not yet been finalized for UTTchain. Until an explicit license is added, do not assume rights beyond those provided by applicable law and GitHub's terms for public repositories.

## Disclaimer

UTTchain is experimental software under active development. Repository documentation describes architecture and development intent, not a promise of future functionality or a representation that any protocol, token migration, market, or trading service is live. Nothing in this repository is investment, tax, or legal advice.
