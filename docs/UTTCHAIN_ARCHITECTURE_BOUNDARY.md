# UTTchain Architecture Boundary

Status: UTTC.0.R2 draft/freeze candidate
Base chain: Robinhood Chain
Evidence baseline: UTTC.0.R1B
UTTchain baseline commit: eba2cfef7cd89c5d4a7bb72ae4811f5feb9322a3
UTT DEV source fingerprint: d762dff132a6d30c979398c6e53bc2da9c9512eda17ac0d536683be5568c55b9

## Purpose

This document defines the initial responsibility boundary between the existing Unified Trading Terminal (UTT), the browser/wallet client, Robinhood Chain smart contracts, external data infrastructure, and optional post-launch services.

It is an architecture policy document. It does not authorize deployment, migration, token mutation, market activation, signing, or broadcast.

## Evidence basis

UTTC.0.R1B inspected the current UTT DEV filesystem in read-only mode and accepted a stable 455-file source corpus:

- backend Python files: 216
- frontend source files: 120
- test files: 24
- FastAPI / HTTP service signal files: 111
- database / persistence signal files: 215
- CEX / exchange-adapter signal files: 281
- Robinhood Chain signal files: 307
- browser-wallet signal files: 78
- signing / key-boundary signal files: 54
- background-work signal files: 33
- FIFO / tax / accounting signal files: 123
- auth / session signal files: 220
- RPC / oracle / indexer signal files: 250

These are discovery signals, not ownership counts. The UTT DEV tree contains historical, suffixed, test, and diagnostic variants, so a signal count must not be interpreted as the number of active production components.

UTT_PUBLISH is the publication/reconciliation workspace for the existing UTT terminal. It is not part of the UTTchain runtime architecture and is out of scope for this boundary.

## Classification model

A. Robinhood Chain / smart contract
B. Browser / wallet client
C. Replaceable RPC / oracle / indexer infrastructure
D. Optional post-launch hosted or serverless service
E. Existing local UTT only
F. Rejected from UTTchain core

A component may legitimately span more than one class when authority is split. The canonical authority must remain explicit.

## Responsibility matrix

| Responsibility | Current UTT evidence | Target class | Launch dependency | Canonical authority | Boundary |
| --- | --- | --- | --- | --- | --- |
| UTTT canonical chain/contract identity | Token/chain identity signals exist throughout UTT | A | Yes | Onchain registry / canonical deployment record | Never symbol-only |
| UTTchain module/version identity | New UTTchain capability | A | Yes | Onchain registry | Versioned module identity required |
| Canonical protocol state and settlement rules | Robinhood Chain execution signals exist | A | Yes | Smart contracts | Deterministic and externally verifiable |
| User transaction authorization | Browser-wallet signals exist | B + A | Yes | User wallet signature plus contract validation | Infrastructure must not silently become signer |
| Browser transaction construction and simulation | Browser-wallet / Robinhood Chain signals exist | B | Yes | User-visible client state | Must validate chain, address, calldata, value, and approval scope |
| Direct DEX execution | Robinhood Chain execution path exists in UTT | B + A | Where supported | User wallet and target protocol contracts | No backend custody or hidden broadcast |
| Token approvals | Existing finite-approval discipline | B + A | Where required | User wallet transaction | Unlimited approvals rejected by default |
| Chain reads and balance reads | RPC/provider signals are widespread | B + C | Yes | Chain state | Provider is transport, not canonical authority |
| Historical chain indexing | RPC/indexer signals are widespread | C | Optional for core correctness where direct reads suffice | Chain remains source of truth | Indexer must be replaceable and reconcilable |
| External market-data delivery | Provider/oracle signals exist | C + A when verified onchain | Feature-specific | Signed/verifiable source plus contract verification when used onchain | No unsigned service response becomes canonical protocol state |
| Portfolio rendering | Frontend source present | B | Yes for web UX | Derived client view | Rendering is not protocol authority |
| Public protocol metadata | New UTTchain capability | A + B | Yes | Onchain records, rendered in browser | Browser cache may accelerate but not override |
| CEX exchange adapters | Extensive CEX adapter evidence | E initially; D optional later | No | Existing UTT or separately scoped optional service | Not part of launch/core UTTchain |
| CEX API credentials and secrets | Auth/key-boundary signals exist | E initially; D optional later | No | Private user/service secret store | Never onchain; never in frontend bundle |
| CEX order submission | Existing UTT responsibility | E initially; D optional later | No | Explicitly authorized CEX boundary | Must not become mandatory for UTTchain core |
| Local SQLite / terminal persistence | Database/persistence signals are widespread | E | No | Existing UTT local data | Not migrated onchain by default |
| FIFO lots / tax basis / local accounting | FIFO/accounting signals are widespread | E; D optional later for private service | No | Existing UTT accounting records | Private financial records must not be made public onchain |
| Background refresh/workers | Background-work signals exist | E; D optional later | No | Existing UTT or optional service | Core protocol cannot depend on an always-on local worker |
| Private notes/profile/application state | Auth/session and persistence signals exist | B/E; D optional later | No | User-private storage | Not canonical public chain state |
| Hosted web session/authentication | Existing auth/session signals | D only if a hosted service is added | No | Optional service session | Wallet-native core use must remain possible without it |
| Optional notification/automation service | Future extension | D | No | Optional service | Additive only; failure cannot invalidate chain state |
| Contract upgrade authority | Future component-specific capability | A | No blanket requirement | Explicit bounded governance/admin authority | Only where justified; must be visible and reviewable |
| Critical UTTT supply authority | Future canonicalization decision | A | If a new canonical token is required | Explicit token contract rules | Must not become upgradeable solely for convenience |
| Cross-chain UTTT representation/migration | Future UTTC.1/UTTC.2 work | A + C depending mechanism | Not yet | Evidence-driven canonical supply architecture | No migration before cross-chain supply reconciliation |
| UTT_PUBLISH workspace | Existing UTT publication workspace | E / operational tooling | No | Existing UTT release process | Explicitly outside UTTchain runtime architecture |

## Rejected core designs

The following are rejected from UTTchain launch/core architecture:

1. Mandatory localhost companion server or daemon.
2. Mandatory second user-operated machine.
3. Mandatory project-operated application server for core protocol use.
4. Backend or hosted infrastructure silently holding user signing authority.
5. CEX API credentials stored onchain or shipped in frontend bundles.
6. Symbol-only token or protocol identity.
7. Unlimited token approvals by default.
8. Public onchain publication of private portfolio, tax-basis, strategy, credential, or note data.
9. Hidden or undocumented privileged roles.
10. Blanket proxy upgradeability applied to every contract.
11. Hosted/indexer/oracle state silently replacing canonical onchain state.
12. Automatic retry after uncertain financial authority without reconciliation.

## Launch architecture invariant

UTTchain launch/core must remain usable without a separate local daemon and without a mandatory project application server.

The target launch path is:

browser
+ wallet
+ Robinhood Chain
+ replaceable RPC/oracle/indexer infrastructure where technically required

The existing local UTT may integrate with UTTchain but is not a required runtime dependency for UTTchain web/onchain functions.

## Optional post-launch services

Hosted or serverless services may be added later for capabilities such as:

- indexing and caching
- private application state
- notifications
- CEX integrations
- advanced analytics
- automation

Such services are additive by default. They must not silently replace canonical onchain authority, silently become a signer, or make previously server-independent core functions unusable when the service is unavailable.

## Upgradeability policy

Upgradeability is component-scoped, not blanket.

Preferred evolution order:

1. Add browser/service capabilities without changing canonical contracts.
2. Add new versioned or modular contracts.
3. Explicitly migrate or supersede immutable components where justified.
4. Use proxy-based upgrades only when a specific component demonstrates a real need.

Any upgradeable component must define bounded authority, storage-layout review, upgrade-path tests, initialization safety, deployment/runtime reconciliation, version visibility, and a migration/recovery model.

## Privacy boundary

The following data is private by default and must not become public protocol state merely for implementation convenience:

- CEX credentials
- private portfolio composition not already public by chain address
- tax basis and FIFO lots
- strategy data
- private notes
- personal identity/profile data
- service session credentials

Onchain data is public unless a separate privacy technology provides a reviewed guarantee.

## Authority split

UTTchain should use the narrowest authority necessary:

- smart contracts: deterministic canonical state and protocol rules
- browser wallet: user authorization and transaction signing
- RPC/indexer/oracle: replaceable data transport or externally verified data
- optional service: non-canonical convenience or private functionality
- existing UTT: local/CEX/accounting responsibilities that do not belong in core protocol

## Current freeze status

This document freezes the first responsibility boundary only.

It does not yet freeze:

- the UTTT canonical supply model
- cross-chain migration mechanics
- exact contract interfaces
- governance roles
- oracle provider selection
- indexer provider selection
- optional hosted-service implementation
- mainnet deployment parameters

Those require later UTTC tranches and explicit acceptance.

## Next architecture gates

UTTC.0.R3: trust and threat map.
UTTC.0.R4: server-independent launch specification.
UTTC.0.R5: optional service and upgradeability boundary.
UTTC.0.R6: RPC/oracle/indexer trust model.
UTTC.0.R7: privacy and data classification.
UTTC.0.FINAL: architecture freeze.
