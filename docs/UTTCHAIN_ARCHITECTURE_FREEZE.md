# UTTchain Architecture Freeze

Status: UTTC.0.FINAL freeze candidate
Base chain: Robinhood Chain
Architecture sequence: UTTC.0.R2A -> R3 -> R4 -> R5A -> R6 -> R7
R7 commit: f9c0c092e25340627a1399e85f55a30c52075829
R7 blob: 9a1d1322412b6eca48ea3917884c02cbff2e1f3e

## Purpose

This document reconciles and freezes the complete UTTC.0 architecture set before UTTT forensic supply intake and before protocol implementation.

UTTC.0 defines where authority belongs, what is trusted, what is optional, what must remain private, how external infrastructure is treated, and what launch independence means.

This freeze is architectural. It does not authorize token migration, contract deployment, proxy deployment, privileged-role assignment, hosted-service activation, signing, broadcast, market activation, bridge activation, or mainnet action.

## Accepted architecture artifacts

| Tranche | Artifact | Bytes | SHA256 | Git blob |
| --- | --- | ---: | --- | --- |
| UTTC.0.R2A | docs/UTTCHAIN_ARCHITECTURE_BOUNDARY.md | 10669 | 13beec02dbfa50fa7c031b905b65bed3c1ac6fdcf82c8b16177daf3eaec5e920 | 9ffd1a361a69bbbbd4afdf38a677043fe040a949 |
| UTTC.0.R3 | docs/UTTCHAIN_THREAT_MODEL.md | 15833 | 729c14806150bd731664221387ac0015ace79131d19e280662033a75581d6265 | 5de0f1294f79f36621de80f6d916adfd7f009955 |
| UTTC.0.R4 | docs/UTTCHAIN_SERVER_INDEPENDENT_LAUNCH.md | 16364 | 2b85a90c6c5e67f4b6f8dfa1ad1f5daf1e4c875188af23ea1a12ed5c2928b8c1 | 6c0e06528dfde7a6656c0e51f43b41dc046c7576 |
| UTTC.0.R5A | docs/UTTCHAIN_OPTIONAL_SERVICES_UPGRADEABILITY.md | 19868 | afa75e66161efcde71630ed245ebfb43af0cfb7ca9b73bda01dd5dc985d63e3b | 25c3c64dd70a1baae33fc72c41d41d723c414dc8 |
| UTTC.0.R6 | docs/UTTCHAIN_RPC_ORACLE_INDEXER_TRUST.md | 22821 | 278470baa2dca2b02e126f97b17f82ca3d6c0161c002809d5a22eb0398047d11 | 046787e3915c316ef6f653cf9ebda2aa219bbfa6 |
| UTTC.0.R7 | docs/UTTCHAIN_PRIVACY_DATA_CLASSIFICATION.md | 26193 | cfeb106d74dcbec00c842d34b6054c694ff267911d6c9d3c1cc0ac977f70d10e | 9a1d1322412b6eca48ea3917884c02cbff2e1f3e |

These six artifacts are the canonical UTTC.0 architecture evidence set.

## Frozen responsibility boundary

UTTchain uses the following responsibility classes:

A. Robinhood Chain / smart contract.
B. Browser / wallet client.
C. Replaceable RPC / oracle / indexer infrastructure.
D. Optional hosted or serverless service.
E. Existing local UTT only.
F. Rejected from UTTchain core.

The authority split is:

- deterministic canonical protocol state belongs on Robinhood Chain
- ordinary user signing authority remains with the user wallet
- the browser constructs, validates, simulates, requests signatures, and renders state
- RPC/indexer/oracle infrastructure transports or derives evidence under explicit trust rules
- optional services are non-canonical by default
- existing UTT CEX/accounting responsibilities remain separate from UTTchain core

Symbol-only identity is not accepted. Canonical identity requires chain and contract/deployment/version evidence appropriate to the component.

## Server-independent launch freeze

Core launch use must not require:

- the existing UTT process
- UTT_PUBLISH
- a localhost API
- a Python or Node daemon
- a local database service
- a background worker
- a signing bridge
- a companion desktop agent
- a second always-on machine
- a mandatory project application API

The launch target is:

static/browser client
+ user wallet
+ Robinhood Chain
+ replaceable RPC infrastructure
+ feature-scoped oracle/indexer infrastructure only where required

Static asset hosting is permitted and replaceable. Static delivery does not become canonical protocol authority.

Developer tooling, Foundry, local test nodes, deployment scripts, and build systems are engineering dependencies, not end-user runtime dependencies.

## Trust and failure freeze

The browser, RPC endpoints, indexers, caches, optional hosted services, metadata sources, and future cross-chain transports are not assumed honest.

Security-critical failures use fail-closed or HOLD behavior according to consequence.

Examples:

- wrong chain: fail closed
- wrong contract/code identity: fail closed
- invalid or stale oracle data: fail closed
- same-block provider disagreement: HOLD and reconcile
- uncertain transaction outcome: HOLD and reconcile
- missing indexer record: unknown/incomplete, not proof of absence
- optional-service outage: isolate/degrade, not authority transfer
- gas or state-growth amplification: redesign rather than assume capacity
- cross-chain supply uncertainty: no migration

A timeout, missing receipt, provider disagreement, or indexer omission does not by itself authorize a duplicate financial action.

Automatic financial retry after uncertain authority remains prohibited until canonical reconciliation establishes the prior outcome.

## RPC, indexer, cache, and oracle freeze

For onchain facts, Robinhood Chain consensus and accepted contract state are canonical.

RPC endpoints are replaceable observation/transport paths.

Indexers are derived-data systems. They may accelerate history, search, pagination, and analytics but do not establish canonical settlement, runtime code identity, privileged roles, or supply authority.

Caches are discardable performance state. Cache loss or corruption must not change canonical protocol state.

Oracle transport is distinct from oracle validity.

An externally originated value may influence canonical onchain state only under an explicitly accepted mechanism that defines, as applicable:

- verifier identity
- feed/report identity
- chain/domain
- report schema
- freshness/timestamps
- units/decimals
- bounds
- replay/duplicate behavior
- invalid/stale behavior
- fallback behavior
- configuration/version behavior

Unsigned hosted values are not an implicit oracle fallback.

No production RPC vendor, indexer, oracle provider, or oracle feed is frozen by UTTC.0.

## Optional-service freeze

Optional hosted/serverless services may later provide:

- caching
- indexed search/history
- analytics
- notifications
- private preferences
- private notes
- separately authorized CEX integration
- bounded automation
- monitoring/telemetry
- other additive capabilities

They are non-canonical by default.

Optional-service authentication is not transaction authorization.

Optional services do not receive general user signing authority.

Any future delegated authority must be separately specified, explicitly bounded, independently revocable where the mechanism permits, and visible enough for a user to understand the grant.

A service must not become an undisclosed upgrade control plane, canonical registry, or hidden signer merely because it is operationally convenient.

## Upgradeability freeze

UTTchain does not adopt blanket proxy architecture.

Preferred protocol evolution order:

1. Browser/client or optional-service changes that do not alter canonical contracts.
2. New immutable or versioned contracts/modules.
3. Explicit migration or supersession where state or authority must move.
4. Component-specific proxy/equivalent upgradeability only when a demonstrated requirement justifies it.

Every upgradeable component requires explicit treatment of:

- exact authority
- funds/supply/code-changing capability
- multisig/timelock analysis
- storage layout
- initialization
- upgrade-path tests
- source and runtime identity
- migration/recovery
- events/version visibility
- compromise consequence
- post-upgrade state reconciliation

Critical UTTT token/supply authority must not become upgradeable merely for convenience.

No proxy deployment or privileged-role assignment is authorized by UTTC.0.

## Privacy and data freeze

UTTchain uses the following initial data classes:

- P0 Public canonical
- P1 Public derived
- P2 Private user/application data
- P3 Secret credential/signing material
- P4 Sensitive operational/security data
- P5 Ephemeral/transient processing data

Robinhood Chain public state, calldata, transaction metadata, and events are treated as public.

Public wallet addresses are public but are not assumed anonymous.

Hashing or encoding does not automatically make private data safe for public-chain publication.

P2 data remains local or in an explicitly optional private service by default.

Examples include private notes, preferences, private CEX portfolio aggregation, FIFO/tax lots, cost basis, and strategy configuration.

P3 data is prohibited from public Git, static frontend bundles, public chain state, public logs, screenshots, and ordinary telemetry.

Examples include seed phrases, wallet private keys, CEX API secrets, private provider keys, service session secrets, and operator signing material.

Core UTTchain does not custody user wallet private keys.

Browser-local storage is not treated as a high-assurance secret store.

Provider/oracle cryptographic validity does not make request metadata private.

Telemetry is optional and non-canonical and must not be required for core protocol use.

## Existing UTT boundary

The existing Unified Trading Terminal remains a separate application boundary.

Its CEX adapters, local persistence, FIFO/tax accounting, background workers, private balances, credentials, and private notes do not become UTTchain core dependencies or public protocol state.

UTT may later integrate with UTTchain while preserving:

- exact identity
- explicit wallet or CEX authority
- private-data separation
- independent failure domains
- canonical chain reconciliation

UTT_PUBLISH remains the existing UTT publication/reconciliation workspace. It is not a UTTchain runtime dependency, canonical authority, signing authority, or private-data authority.

## UTTT and cross-chain boundary

UTTC.0 does not select the canonical UTTT supply model.

UTTC.1 must forensically reconcile economically live UTTT supply and administrative authority across:

- Robinhood Chain
- Solana
- Polkadot / Asset Hub / Hydration
- Counterparty

Nominal supplies must not simply be summed.

Any future migration, bridge, representation, lock/mint, burn/mint, redemption, or cross-chain message mechanism remains blocked until the economic-supply model is reconciled and accepted.

Cross-chain implementation also requires a separate trust, replay-domain, finality, failure-recovery, supply-conservation, and privacy/linkability analysis.

## Implementation gate

UTTC.0 architecture acceptance is a prerequisite, not implementation acceptance.

A later component may move from specification toward production only through the gated lifecycle appropriate to its risk:

specification
-> local implementation
-> unit tests
-> invariant/fuzz tests
-> static/security analysis
-> fork/read-only validation where applicable
-> testnet where applicable
-> deployment reconciliation
-> explicit production/security acceptance
-> separately authorized mainnet action

No production deployment may rely on uncommitted source.

A successful transaction is not sufficient deployment acceptance.

Source, commit, build/toolchain inputs, deployed/runtime code, initialization, roles, and critical state must be reconciled.

## Architecture regression criteria

A later design is an architecture regression unless explicitly re-opened and accepted if it:

- makes core use depend on a localhost daemon
- makes core use depend on the existing UTT backend
- makes core use depend on UTT_PUBLISH
- makes core use depend on a private project application API
- transfers ordinary signing authority away from the user wallet without a separately accepted bounded-authority design
- treats an RPC/indexer/cache as canonical protocol authority
- treats unsigned hosted data as an oracle fallback
- introduces symbol-only identity
- introduces unlimited approvals by default
- makes optional services mandatory without an accepted architecture change
- applies blanket proxy upgradeability
- creates undocumented privileged roles
- makes critical UTTT supply authority upgradeable merely for convenience
- publishes P2/P3/P4 data onchain without an accepted component-specific reason
- places P3 secrets in Git, browser bundles, logs, telemetry, or public chain state
- automatically retries an uncertain financial action before reconciliation
- begins cross-chain UTTT migration before accepted economic-supply reconciliation

Architecture changes are permitted, but they must be explicit, evidence-backed, versioned, and re-accepted rather than silently introduced through implementation.

## Frozen UTTC.0 invariants

1. Canonical deterministic UTTchain protocol state belongs on Robinhood Chain.
2. Core ordinary user signing remains with the user wallet.
3. Core launch is server-independent and does not require existing UTT, UTT_PUBLISH, localhost, or a project application API.
4. Exact chain/contract/deployment/version identity supersedes symbol-only identity.
5. RPC endpoints are replaceable transport, not canonical authority.
6. Indexers and caches are derived/non-canonical.
7. Oracle transport is not oracle validity.
8. Oracle-dependent canonical transitions require an exact accepted verification envelope.
9. Financial ambiguity enters HOLD until reconciled.
10. Automatic financial retry under uncertainty is prohibited.
11. Optional hosted services are additive and non-canonical by default.
12. Optional-service authentication is not transaction authorization.
13. Optional services do not receive general user signing authority by default.
14. Blanket proxy architecture is rejected.
15. Upgradeability is component-specific and must be justified.
16. Every privileged role must be explicit, narrow, observable, and documented.
17. Critical UTTT supply authority must not be upgradeable merely for convenience.
18. Robinhood Chain storage, calldata, and events are treated as public.
19. Public wallet addresses are not assumed anonymous.
20. P2 private data remains offchain by default.
21. P3 credentials/signing material is prohibited from public Git, frontend bundles, public chain state, logs, screenshots, and ordinary telemetry.
22. Existing UTT CEX/accounting/private-data systems remain outside UTTchain core authority.
23. Cross-chain UTTT migration remains blocked pending accepted economic-supply reconciliation and later component-specific security analysis.
24. Production deployment requires source-to-runtime and state reconciliation.
25. Mainnet signing/broadcast remains separately authorized.
26. UTTC.0 architecture changes must be explicitly reopened and re-accepted.

## Deferred decisions

UTTC.0 deliberately does not freeze:

- UTTT canonical supply model
- UTTT canonical contract address
- cross-chain migration mechanism
- bridge/message transport
- exact UTTchain contract interfaces
- governance/admin addresses or signers
- multisig threshold
- timelock duration
- proxy standard or any upgradeable component
- production RPC provider
- production indexer
- oracle mechanism/feed
- oracle freshness/bounds
- optional hosted-service provider
- static hosting provider
- telemetry provider
- database/encryption implementation
- retention durations
- exact legal/compliance implementation
- market activation parameters
- mainnet deployment parameters

These decisions belong to later evidence-driven tranches.

## UTTC.0 completion condition

UTTC.0 is complete when:

- all six architecture artifacts above match their accepted byte, SHA256, and Git-blob identities
- local and remote main reconcile to the final architecture-freeze commit
- the architecture-freeze artifact is exact
- predecessor artifacts remain unchanged
- the final worktree is clean
- no unauthorized chain, signing, deployment, migration, market, or hosted-service action occurred

After UTTC.0 acceptance, the next phase is UTTC.1 multi-chain UTTT forensic intake and economic-supply reconciliation.

## Authorization status

UTTT canonical supply: NOT YET FROZEN.
UTTT migration: NOT AUTHORIZED.
Token deployment: NOT AUTHORIZED.
Proxy deployment: NOT AUTHORIZED.
Hosted-service activation: NOT AUTHORIZED.
Privileged-role assignment: NOT AUTHORIZED.
Market activation: NOT AUTHORIZED.
Mainnet signing/broadcast: NOT AUTHORIZED.
