# UTTchain Trust and Threat Model

Status: UTTC.0.R3 draft/freeze candidate
Base chain: Robinhood Chain
Architecture boundary: UTTC.0.R2A
Architecture boundary commit: 6e054241291d239bac1e18062e313d52c826b3fc
Architecture boundary blob: 9ffd1a361a69bbbbd4afdf38a677043fe040a949

## Purpose

This document freezes the initial UTTchain trust model, threat surfaces, security invariants, and failure dispositions before contract implementation.

It does not authorize token migration, deployment, signing, broadcast, market activation, bridge activation, or mainnet action.

## Security objective

UTTchain minimizes trusted infrastructure while preserving explicit user authorization and deterministic onchain authority.

Launch/core remains:

browser
+ user wallet
+ Robinhood Chain
+ replaceable RPC/oracle/indexer infrastructure where technically required

Mandatory localhost daemons, mandatory companion machines, mandatory project application servers, hidden backend signers, and blanket proxy authority are rejected.

## Protected assets

The model protects:

1. User transaction authority and funds.
2. UTTT canonical identity and future supply authority.
3. UTTchain contract/module identity and settlement state.
4. Token approval and allowance scope.
5. Deployment source, bytecode, initialization, and provenance.
6. Registry/version/capability state.
7. Oracle-authenticated values used onchain.
8. Future cross-chain supply or representation state.
9. Private keys, CEX credentials, and service credentials.
10. Private portfolio, accounting, strategy, and note data.
11. Repository/release integrity.
12. Reconciliation evidence after uncertain financial actions.

## Trust anchors

### Robinhood Chain consensus

Canonical contract state and finalized transaction results derive from Robinhood Chain consensus. A single RPC endpoint is only an observation surface and is not itself canonical authority.

### User wallet

The wallet is the signing boundary for core launch transactions. The application may construct, simulate, explain, and request an action but may not silently become the signer.

### Canonical identity

Chain ID, contract address, deployment/version identity, and code identity are authoritative together. Token symbols, names, UI labels, caches, and third-party listings are insufficient.

### Repository and deployment evidence

Accepted source, commit identity, toolchain/compiler configuration, deployment inputs, runtime bytecode, initialized state, and chain identity form the deployment provenance boundary.

### Verified external data

External data becomes protocol-authoritative only through an explicitly reviewed verification mechanism. Unsigned HTTP responses and arbitrary hosted-service responses are not canonical protocol authority.

## Trust zones

| Zone | Examples | Authority |
| --- | --- | --- |
| Z1 Onchain | UTTchain contracts, registry, settlement state | Canonical protocol state after chain consensus |
| Z2 Wallet | Browser/hardware/account-abstraction wallet | User transaction authority |
| Z3 Browser | UTTchain web client | Untrusted execution environment; no independent signing |
| Z4 External data transport | RPC, indexer, oracle delivery | Replaceable observation/data path |
| Z5 Optional hosted service | Cache, analytics, notifications, private integrations | Non-canonical by default |
| Z6 Existing UTT | Local terminal, CEX adapters, accounting, persistence | Separate application authority only |
| Z7 Development/deployment | GitHub, Foundry, scripts, deployment account | Build/provenance boundary; no automatic production authority |

## Adversary model

The design assumes an attacker may:

- compromise a browser origin, extension, injected script, or local browser state
- return false, stale, censored, inconsistent, or selectively omitted RPC results
- return stale or fabricated indexer data
- compromise an optional hosted service or cache
- exploit malicious token behavior
- induce deceptive approvals or transaction prompts
- exploit reentrancy, authorization, initialization, upgrade, storage, arithmetic, or accounting defects
- exploit stale oracle data or incorrect verifier/feed assumptions
- front-run or reorder public transactions where chain mechanics permit
- exploit nonce, replacement, timeout, receipt, or reconciliation races
- publish a fake token/contract using the same symbol or name
- compromise privileged admin or upgrade authority
- compromise source, dependencies, release, or deployment tooling
- replay signatures across chains, contracts, sessions, or domains if separation is weak
- create denial-of-service through gas amplification, state growth, provider failure, or external dependency failure
- exploit future bridge/cross-chain assumptions if such functionality is introduced

The browser, RPC, indexer, optional service, token metadata source, and CEX API are not assumed honest merely because the project configured them.

## Threat matrix

| Threat | Surface | Required control | Disposition |
| --- | --- | --- | --- |
| Wrong-chain execution | Browser/wallet/RPC | Exact chain ID validation before signing and reconciliation | Fail closed |
| Fake token/contract | UI/metadata | Chain ID + address + deployment/version/code identity | Fail closed |
| Calldata substitution | Browser | Show/validate target, function, value, amounts, approvals, critical parameters | Fail closed |
| Unlimited approval escalation | Browser/integration | Finite approval policy and explicit spender identity | Reject by default |
| Malicious RPC response | RPC | Replaceability, sanity checks, code/address checks, receipt reconciliation | Hold/fail closed |
| Stale indexer state | Indexer | Treat as derived; reconcile canonical decisions against chain | Degrade only |
| Invalid/stale oracle report | Oracle | Verify identity, freshness, units, bounds, and verifier rules | Fail closed |
| Optional service compromise | Hosted service | No canonical authority or silent signing; scoped credentials | Isolate service |
| Hidden backend signer | Service/local process | Prohibited in core architecture | Reject |
| Browser/wallet compromise | Wallet/browser | Minimize requested authority, explicit review, bounded approvals | Residual user-security risk |
| Reentrancy | Contracts | CEI/pull patterns/guards where justified plus tests | Fail tests/audit |
| Access-control defect | Contracts | Explicit least-privilege roles and negative tests | Fail tests/audit |
| Upgrade-key compromise | Upgradeable component | Avoid unless justified; bounded multisig/timelock authority | Component emergency process |
| Storage-layout corruption | Proxy component | Layout review and upgrade simulation/tests | Reject upgrade |
| Initialization attack | Deployment/proxy | Protected/atomic initialization and state reconciliation | Reject deployment |
| Deployment mismatch | Build/deploy | Pin toolchain and reconcile address, code, inputs, state | Not accepted |
| Nonce/replacement ambiguity | Wallet/chain | Reconcile tx/receipt/nonce before retry | Hold |
| Automatic retry after uncertainty | Client/service | Prohibited before canonical reconciliation | Hold |
| Replay | Signatures/cross-chain | Chain/domain/contract/nonce/deadline separation | Fail closed |
| Slippage/price manipulation | DEX/oracle | Explicit user-visible min/max bounds and deadlines | Reject/out-of-bounds |
| Malicious ERC-20 | Token integration | Safe transfer handling and explicit compatibility assumptions | Unsupported/fail closed |
| Gas/state amplification | Contracts | Bounded work, state-growth analysis, gas benchmarks | Redesign |
| Front-running/MEV | Public mempool | Slippage/deadline bounds; no false MEV guarantees | Residual within bounds |
| Repository compromise | Supply chain | Protected main, CI/review when available, pinned toolchain/dependencies | Block release |
| Secret leakage | Repo/frontend/logs | No secrets in Git/frontend; scoped storage and redaction | Rotate/respond |
| Private-data publication | Chain/logging | Data classification before write; public-chain assumption | Fail closed |
| CEX authority bleed | Existing UTT/service | Keep CEX authority non-core and optional | Architecture violation |
| Cross-chain supply duplication | Future migration | Complete UTTC.1 economic-supply reconciliation first | No migration |
| Bridge/message compromise | Future cross-chain | Separate bridge trust/finality/replay/recovery model | No activation |

## Browser and wallet requirements

Before requesting wallet authority, the client must validate and present, as applicable:

- chain ID and connected account
- destination contract and action
- ETH value
- token identity by address
- token amount and spender
- approval amount
- slippage/execution bounds
- deadline/expiry
- expected state transition
- simulation result when available

Core infrastructure must not retain user private keys or seed phrases.

Exact or finite approvals are preferred. Unlimited approvals are rejected by default. Permit-style signatures, if later supported, require explicit domain, nonce, deadline, spender, token, and amount review.

Any later account-abstraction session key or delegated authority requires a separate specification bounding action, asset, amount, target, time, and revocation semantics.

## RPC, indexer, and oracle requirements

RPC and indexer infrastructure is replaceable and non-canonical.

Critical controls include expected chain ID, contract code/identity checks, explicit finality assumptions, receipt reconciliation, timeout/retry discipline, stale-data handling, provider failover, chain-first canonical reconciliation, and cache invalidation.

A provider outage may degrade the interface but must not corrupt canonical state.

No oracle provider is frozen here. Before oracle-controlled state transitions exist, later design must define exact feed/report and verifier identity, freshness, timestamp semantics, decimal/unit normalization, bounds, invalid/stale behavior, fallback policy, and network assumptions.

Unsigned hosted prices are insufficient authority for an onchain transition.

## Smart-contract and privileged-authority requirements

Implementation review must cover:

- access control and initialization
- ownership/admin transfer
- pause/emergency authority if present
- upgrade authority if present
- external calls and callbacks
- reentrancy
- token transfer semantics
- arithmetic/precision
- state growth and loop bounds
- denial-of-service paths
- events
- unit, invariant, fuzz, and fork/read-only tests where applicable
- deployment/runtime reconciliation

Any privileged authority must be explicit, narrow, observable, and justified.

Before production, every privileged action must state who can call it, what it can change, whether it can move funds/change supply/change code, whether multisig/timelock applies, emitted events, recovery/revocation, and compromise consequence.

Critical UTTT supply authority must not be upgradeable merely for convenience.

## Deployment and reconciliation requirements

A successful deployment transaction is not sufficient acceptance.

Production acceptance must bind:

accepted source
+ exact commit
+ dependency/toolchain/compiler settings
+ constructor/initialization inputs
+ deployment provenance
+ deployed address
+ runtime bytecode
+ initialized state
+ chain identity

Uncommitted source must not be the production deployment source. Mainnet broadcast always requires a separate explicit authorization gate.

Any financially authoritative action with uncertain outcome enters HOLD until canonical state is established. This includes wallet hash/receipt uncertainty, timeout after possible broadcast, provider disagreement, replacement ambiguity, unexpected nonce movement, or future bridge/message uncertainty.

No automatic retry is allowed merely because success was not observed.

## Existing UTT and optional-service boundary

The existing UTT remains a separate application boundary. Its CEX adapters, local database, FIFO/tax accounting, background workers, and private credentials do not become UTTchain core dependencies.

UTT may later consume UTTchain data or construct compatible actions, but integration must preserve exact identity, explicit authority, independent failure domains, and no hidden signing transfer.

UTT_PUBLISH remains an existing UTT publication/reconciliation workspace and is not a UTTchain runtime dependency.

A future hosted/serverless service is non-canonical by default. It may provide caching, private state, notifications, analytics, automation, or separately authorized integrations, but it must not establish canonical truth or silently acquire signing authority.

## Cross-chain boundary

Cross-chain UTTT migration, representation, bridge, burn/mint, lock/mint, or redemption mechanics are not authorized here.

They remain blocked until UTTC.1 establishes economically live supply and administrative authority across Robinhood Chain, Solana, Polkadot/Asset Hub/Hydration, and Counterparty.

Nominal supplies must not simply be added together to infer economic supply.

Any future bridge/message layer requires separate trust, replay-domain, finality, failure-recovery, and supply-conservation analysis.

## Safety versus liveness

UTTchain distinguishes safety from availability.

Examples:

- stale oracle data: reject according to policy
- unavailable indexer: use chain reads where feasible or degrade history
- unavailable optional service: core browser/onchain functions remain independent
- RPC failure: fail over or report unavailable; never invent state
- gas/state-growth risk: bound work rather than assuming future capacity

The protocol must not trade deterministic safety for silent fallback convenience.

## Residual risks

Residual risks include wallet compromise, user approval of a malicious but clearly displayed transaction, Robinhood Chain consensus failure, bugs in external protocols, MEV within accepted bounds, browser/wallet zero-days, retained admin-key compromise, and oracle failure within the accepted oracle design.

Residual risks must be documented rather than described as impossible.

## Frozen security invariants

1. Canonical UTTchain state is onchain, not in a hosted database.
2. Core launch signing remains with the user wallet.
3. A single RPC/indexer response is not canonical authority.
4. Symbol-only identity is prohibited.
5. Unlimited approvals are rejected by default.
6. Automatic retry after uncertain financial authority is prohibited until reconciliation.
7. Private keys and CEX credentials are prohibited from public chain state and frontend bundles.
8. Existing UTT CEX/accounting infrastructure is not a required UTTchain core dependency.
9. Optional hosted services are non-canonical by default.
10. Upgradeability must be component-specific and justified.
11. Production deployment requires source-to-runtime reconciliation.
12. UTTT migration remains prohibited until cross-chain economic-supply reconciliation is accepted.
13. Private financial/application data is not published onchain for convenience.
14. Onchain work must be bounded or demonstrated production-safe.
15. Mainnet broadcast requires separate explicit authorization.

## Current freeze status

This document freezes the trust/threat model only.

It does not select exact contract interfaces, governance addresses/signers, oracle feed/provider, RPC provider, indexer provider, hosted-service provider, proxy implementation, bridge transport, UTTT canonical supply model, or mainnet parameters.

## Next architecture gates

UTTC.0.R4: server-independent launch specification.
UTTC.0.R5: optional service and upgradeability boundary.
UTTC.0.R6: RPC/oracle/indexer trust model.
UTTC.0.R7: privacy and data classification.
UTTC.0.FINAL: architecture freeze.
