# UTTchain Privacy and Data Classification

Status: UTTC.0.R7 draft/freeze candidate
Base chain: Robinhood Chain
Architecture boundary: UTTC.0.R2A
Threat model: UTTC.0.R3
Server-independent launch: UTTC.0.R4
Optional services and upgradeability: UTTC.0.R5A
RPC/oracle/indexer trust model: UTTC.0.R6
R6 commit: c39614e121dc929ec08cf5636171a076669ff608
R6 blob: 046787e3915c316ef6f653cf9ebda2aa219bbfa6

## Purpose

This document freezes the initial privacy and data-classification boundary for UTTchain before contract implementation and before any hosted-service implementation.

The objective is to keep public protocol facts public and verifiable while preventing private financial, credential, identity, strategy, and operational data from becoming public or canonical merely for implementation convenience.

This document is an engineering classification and handling policy. It is not a representation that public blockchains provide confidentiality, and it does not replace jurisdiction-specific legal or compliance review where such review is required.

This document does not authorize collection of new personal data, deployment, token migration, signing, broadcast, market activation, bridge activation, privileged-role assignment, hosted-service activation, or mainnet action.

## Fundamental privacy premise

Robinhood Chain is a public blockchain.

Data written to contract storage, transaction calldata, transaction value, logs/events, or otherwise recoverable from public chain execution must be treated as public unless a separately reviewed privacy mechanism provides a concrete confidentiality guarantee.

Hashing, encoding, truncation, or replacing a value with an identifier does not automatically make sensitive data safe to publish.

The preferred privacy control is data minimization: do not place private data onchain when the protocol does not require it.

## Classification levels

UTTchain uses six initial data classes.

### P0 - Public canonical

Data intentionally made public and authoritative through accepted onchain protocol state.

Examples:

- canonical chain and contract identity
- module/version identity
- protocol parameters
- public roles/administrative addresses
- public token balances and allowances observable onchain
- public supply state
- public settlement state
- public governance or upgrade events where applicable

P0 may be stored onchain when required by protocol design.

### P1 - Public derived

Data derived from public sources but not itself canonical authority.

Examples:

- indexed event history
- portfolio views derived solely from public wallet activity
- explorer-style transaction views
- cached contract metadata
- public analytics
- public aggregate metrics
- quote candidates not yet executed
- rendered protocol status

P1 may be stored or cached offchain, but must retain provenance/freshness appropriate to its use and must not silently override P0.

### P2 - Private user/application data

Data that may be useful to a user or application but should not become public protocol state by default.

Examples:

- private notes
- private watchlists
- private labels
- user preferences
- private alert rules
- local portfolio grouping
- user-entered cost basis
- FIFO/tax lots
- tax/accounting adjustments
- private strategy configuration
- private CEX portfolio aggregation
- optional-service profile settings

P2 belongs in user-controlled local storage or an explicitly optional private service with a defined data-handling boundary.

### P3 - Secret credential/signing material

Data whose disclosure can directly grant authentication, signing, spending, or service authority.

Examples:

- seed phrases
- wallet private keys
- raw signing keys
- CEX API secrets
- CEX private authentication tokens
- database passwords
- private provider API keys
- session secrets
- encryption master keys
- privileged operator signing material

P3 is prohibited from public Git, static frontend bundles, public chain state, public logs, screenshots, and ordinary telemetry.

Core UTTchain launch infrastructure must not require custody of user wallet private keys.

### P4 - Sensitive operational/security data

Data that is not necessarily a user secret but can increase attackability or disclose security-sensitive operational context.

Examples:

- non-public infrastructure credentials or endpoint metadata
- unreleased deployment plans
- private admin rotation plans
- incident-response notes
- security findings before coordinated disclosure
- internal rate-limit or abuse-control details
- non-public monitoring topology
- sensitive service architecture not required for public verification

P4 should be access-controlled and minimized. Public disclosure may be appropriate later when the security consequence has been addressed or the information becomes part of accepted protocol transparency.

### P5 - Ephemeral/transient processing data

Data required temporarily to perform a task but not required for durable retention.

Examples:

- temporary transaction simulation response
- transient RPC error body
- temporary nonce used for web authentication
- short-lived session challenge
- temporary oracle transport response before verification
- in-memory derived calculation
- temporary upload used for a user-requested operation

P5 should be discarded when its operational purpose ends unless it is promoted into another explicit class for a documented reason.

## Classification matrix

| Data | Class | Canonical? | Onchain? | Static frontend? | Optional private service? |
| --- | --- | --- | --- | --- | --- |
| Chain ID | P0 | Yes for network identity | Reference/implicit | Yes | Yes |
| Canonical contract address | P0 | Yes | Registry/deployment state where designed | Yes as cache/reference | Yes as cache |
| Runtime/module version | P0 | Yes | Yes where protocol requires | Yes as derived display | Yes as cache |
| Public wallet address | P0/P1 context-dependent | Public fact | Already public when used onchain | Yes when user selects/connects | Yes if needed |
| Public token balance | P0 fact / P1 display | Chain state canonical | Existing chain state | Yes as display | Yes as cache |
| Public transaction hash | P0 fact / P1 index | Chain evidence | Existing chain state | Yes | Yes |
| Indexed transaction history | P1 | No | No need | Yes | Yes |
| Public protocol analytics | P1 | No | No need by default | Yes | Yes |
| Private notes | P2 | No | No | Local only if private | Yes, explicitly optional |
| User preferences | P2 | No | No | Local client state possible | Yes |
| FIFO/tax lots | P2 | No | No | Not in public bundle/state | Yes if user opts in |
| Private CEX balances | P2 | No | No | Not public by default | Yes if explicitly integrated |
| CEX API secret | P3 | No | Never | Never | Only in scoped secret store |
| Wallet seed/private key | P3 | No | Never | Never | Never for ordinary core launch |
| Private provider key | P3 | No | Never | Never if secrecy required | Yes in scoped secret store |
| Service session secret | P3 | No | Never | Never as durable public value | Yes, scoped |
| Unreleased security finding | P4 | No | No | No | Restricted operational store |
| Incident-response detail | P4 | No | No | No | Restricted operational store |
| Auth nonce/challenge | P5 unless retained | No | No | Short-lived client/server use | Yes, short-lived |
| Temporary simulation data | P5/P1 if retained | No | No | In memory/display | Optional |
| Oracle transport response | P5 before validation; P1 evidence if retained | No by itself | Verified report may be submitted if protocol requires | Temporary | Optional |

## Public wallet addresses and pseudonymity

A blockchain address is public when used onchain, but it must not be treated as anonymous in the security model.

Addresses can be correlated with:

- transaction history
- token holdings
- counterparties
- timing
- public usernames or posts
- CEX withdrawal/deposit activity
- browser/provider request metadata
- other chains

UTTchain must not promise anonymity merely because a user is represented by an address rather than a legal name.

Optional services should avoid collecting identity-to-address mappings unless the feature actually requires them.

## Onchain data minimization

Before adding a new storage field, calldata field, event field, or public identifier, design review must ask:

1. Is this datum required for deterministic protocol execution or public verification?
2. Can the protocol use a less revealing value?
3. Can the datum remain browser-local or in an optional private service?
4. Does an event reveal more than contract storage already reveals?
5. Will the datum become permanently linkable to an address?
6. Could the value expose financial strategy, identity, credentials, or private accounting?
7. Is the datum necessary indefinitely, or only transiently?
8. Does later deletion from an offchain system matter if an onchain copy is permanent?

If the public-chain requirement is not demonstrated, private data should remain offchain.

## Events and logs

Events are public data.

A value must not be placed in an event merely because it is convenient for indexing.

Event design must follow the same classification rules as storage and calldata.

Examples that are prohibited from events include:

- API credentials
- private notes
- tax lots
- service session tokens
- plaintext personal identifiers
- secrets used for future authentication
- private strategy parameters unless the protocol explicitly requires them to be public

Event topic indexing can increase discoverability and linkability; this should be considered during interface design.

## Calldata and transaction metadata

Transaction calldata is public.

Private data must not be placed in calldata under the assumption that it is hidden because it is not stored in contract state.

Transaction-level metadata can also reveal:

- sender address
- destination
- value
- timing
- gas behavior
- function selector
- calldata parameters
- approval relationships

A browser must treat transaction construction as preparation of public information unless a reviewed privacy mechanism states otherwise.

## Hashes and identifiers

A hash may protect direct readability but does not automatically provide privacy.

Potential problems include:

- low-entropy values can be brute-forced
- public dictionaries can reveal hashed labels or identifiers
- the hash itself can become a stable correlation identifier
- salting requires a salt-handling model
- later disclosure of the source value retroactively links the hash

UTTchain must not classify P2/P3/P4 data as P0 merely because it is hashed.

If a commitment scheme is later required, it needs a component-specific privacy and cryptographic analysis.

## Browser-local storage

Browser-local storage can be appropriate for non-secret user convenience data, but it is not a high-assurance secret store.

The design must consider:

- script-origin compromise
- browser extensions
- shared devices
- backup/sync behavior
- persistence after logout
- XSS
- accidental export

P3 secrets should not be placed in ordinary localStorage or equivalent persistent browser storage merely for convenience.

Wallet private keys remain inside the wallet's own security boundary, not application storage.

## Optional hosted service

An optional service may store P2 data when the feature requires durable private state and the user opts into that service.

The service specification must define, as applicable:

- purpose of collection
- fields collected
- classification
- retention
- access controls
- encryption boundary
- authentication
- export
- deletion
- backup behavior
- logging/redaction
- incident handling
- provider/subprocessor dependencies where relevant
- canonical reconciliation for public chain-derived fields

The service must remain non-canonical by default under R5.

A hosted service must not require users to upload P3 wallet signing material for ordinary UTTchain core use.

## Existing UTT boundary

The existing Unified Trading Terminal already contains private local/CEX/accounting responsibilities that remain outside UTTchain core.

Examples include:

- CEX credentials
- CEX balances not otherwise public
- local account metadata
- FIFO lots
- cost basis
- tax/accounting records
- private notes
- locally persisted terminal preferences

Integration with UTTchain does not authorize copying these data classes to public chain state.

UTT_PUBLISH is an existing UTT publication/reconciliation workspace and is not a private-data authority or UTTchain runtime component.

## CEX data boundary

CEX data requires explicit separation between public protocol data and private account data.

Public information such as a market symbol or public exchange market specification may be P1.

User-specific data such as:

- API credentials
- account identifiers
- balances
- open orders
- order history
- fills
- deposit/withdrawal records
- account permissions

is P2 or P3 depending on whether possession grants authority.

CEX credentials are P3.

CEX account history and balances are P2 unless the user has separately made them public.

No CEX secret is ever canonical UTTchain protocol state.

## Tax and accounting boundary

FIFO lots, cost basis, acquisition notes, tax classifications, and private accounting adjustments are P2.

They remain in existing UTT or an explicitly optional private service unless a future user-selected export/import feature is designed.

A protocol event should represent the protocol action, not a user's private tax interpretation of that action.

UTTchain must not claim that a public transaction history alone is a complete user tax record.

## Provider and RPC metadata privacy

RPC, indexer, oracle transport, CDN, and optional-service providers may observe metadata even when the payload itself is public or cryptographically verified.

Potential metadata includes:

- IP address
- request timing
- requested wallet address
- requested contract
- method names
- browser/user-agent information
- API account identity
- correlation across repeated requests

R6's cryptographic/canonicality controls do not eliminate this metadata exposure.

Provider selection and browser implementation should minimize unnecessary transmission and avoid sending private application data to public chain-data providers.

## Oracle transport privacy

A cryptographically signed oracle report can be authentic while the request used to retrieve it still leaks metadata.

If a pull-based oracle feature reveals an intended trade, wallet, instrument, or timing signal to a transport provider, that privacy consequence must be considered in the component design.

R7 does not select an oracle mechanism or claim that any current oracle transport is private.

## Logs and diagnostics

Logs must be classified data, not an exception to classification.

Public-safe diagnostics may include:

- step identifiers
- component versions
- non-secret file paths where appropriate
- public transaction hashes
- public contract addresses
- sanitized error classes
- aggregate timings

Logs must redact or omit:

- seed phrases
- private keys
- CEX secrets
- session secrets
- authorization headers
- private provider keys
- encryption keys
- plaintext private notes
- unnecessary private portfolio/accounting data

Error bodies from external services should not be blindly logged because they may echo credentials or private request content.

## Telemetry

Telemetry is optional infrastructure and non-canonical.

Before telemetry is enabled, the implementation should define:

- what is collected
- whether wallet addresses are collected
- whether IP/network metadata is retained by the telemetry provider
- event granularity
- retention
- user controls where applicable
- redaction
- whether telemetry can be disabled without breaking core functions

Telemetry must not become a condition for protocol use.

P3 secrets must never be telemetry fields.

## Authentication data

Authentication data for optional services is separate from transaction authorization.

Examples:

- login nonce: P5
- short-lived session token: P3
- refresh token: P3
- wallet address used as account identifier: P0/P2 contextual metadata
- authentication audit record: P4/P2 depending content

Signed login messages must not contain unnecessary private application data.

A reusable authentication token must never be embedded into a public blockchain transaction.

## Encryption

Encryption can protect P2/P3/P4 data at rest or in transit, but encryption does not change canonicality.

The design must still define:

- key ownership
- key storage
- rotation
- recovery
- backup
- access-control boundary
- what metadata remains visible

Encrypting private data and then publishing ciphertext permanently on a public chain is not accepted merely because the plaintext is currently unreadable; future cryptographic, key-management, correlation, or disclosure risks remain.

Onchain ciphertext requires a separate, explicit privacy design.

## Backups and exports

Private data can leak through backups and exports.

Any optional service holding P2/P3/P4 data should define:

- whether backups exist
- retention after deletion
- encryption
- restore access
- export format
- secret redaction
- deletion semantics

Exports containing P3 secrets must not be generated by default.

Public protocol state should be reconstructible from public chain evidence without requiring restoration of a private service database.

## Data deletion and chain permanence

Offchain systems may support deletion.

Public chain history generally cannot be treated as deletable application storage.

Therefore, a design that may later need deletion, correction, revocation of visibility, or user-controlled erasure should avoid putting the underlying private content onchain in the first place.

A later contract state update does not erase historical calldata, logs, or prior state evidence from public archival systems.

## Data retention

Retention should follow purpose.

P5 data should normally be short-lived.

P2 data should be retained only as long as the user/application purpose requires.

P3 data should be minimized and retained only where required for the authorized capability.

P4 data should follow the operational/security need and disclosure lifecycle.

P0 chain data follows the permanence characteristics of the blockchain and cannot be managed like ordinary private application storage.

R7 does not select exact retention durations for future optional services.

## Access control

Offchain access control must follow least privilege.

Access to P2/P3/P4 should be scoped by role and service purpose.

Administrative access to an optional service does not imply authority to sign user transactions or alter canonical protocol state.

Where human/operator access exists, the later service implementation must define authentication, authorization, auditability, and revocation appropriate to the sensitivity of the data.

## Secret lifecycle

Any component that legitimately handles P3 service/operator secrets must define:

1. generation/source
2. storage
3. access
4. use
5. rotation
6. revocation
7. backup/recovery
8. incident response
9. destruction

This does not authorize UTTchain to custody user wallet signing keys.

If a secret is exposed, it must be treated as compromised rather than made safe by deleting it from a later Git commit.

## Source control and build artifacts

Public Git is a P0/P1 publication surface.

P2/P3/P4 data must not be committed merely because a repository is convenient for synchronization.

`.env` exclusions reduce accidental exposure but are not a substitute for secret scanning, review, and scoped credential handling.

Static frontend bundles are public artifacts.

Any secret required by code shipped to the browser must be assumed recoverable by the user and by an attacker.

## Screenshots, support, and copy-back evidence

Engineering and support workflows can accidentally disclose private data through screenshots, pasted logs, terminal output, or evidence artifacts.

Diagnostic gates should print the minimum evidence necessary.

Where public identifiers are sufficient, private account details should be omitted or redacted.

P3 material must never be requested as copy-back evidence.

If a diagnostic requires proof involving sensitive values, the gate should prefer boolean/presence/hash-derived evidence that does not reveal the secret itself, provided that such evidence is technically adequate.

## Public documentation

Public documentation may include:

- canonical contract addresses after accepted deployment
- network IDs
- public roles
- public protocol parameters
- accepted source/commit/runtime identities
- public threat-model assumptions
- public upgrade/version events

Public documentation should not include P3 secrets or unnecessary P2/P4 details.

Security architecture should be transparent enough to verify authority boundaries without publishing active credentials or avoidable attack-enabling secrets.

## Cross-chain privacy

Future cross-chain UTTT work can increase linkability.

A bridge, burn/mint, lock/mint, or redemption flow may correlate addresses and timing across networks.

UTTC.1 will first reconcile economic supply and authority. Any later cross-chain implementation must separately analyze what identifiers, messages, proofs, and events become public across chains.

R7 does not claim cross-chain privacy and does not authorize cross-chain migration.

## Data incident principles

A privacy/security incident involving offchain data must not be concealed by changing canonical protocol records.

Response should distinguish:

- public chain facts that cannot be made private retroactively
- P2 data requiring containment/deletion/recovery
- P3 secrets requiring revocation/rotation
- P4 operational information requiring controlled handling
- derived P1 caches that can be rebuilt

Incident response must not silently grant new signing or upgrade authority.

## Data-flow review requirement

Before a new feature moves beyond specification, its design must identify:

- data inputs
- source
- classification
- processing location
- storage location
- recipients/providers
- canonicality
- retention
- deletion behavior
- logging/telemetry
- signing/financial authority interaction
- failure behavior

A feature with unknown data placement is not architecture-ready.

## Test requirements

Later implementation acceptance must test, as applicable:

- no seed/private key enters application logs
- no CEX secret enters Git or frontend output
- no secret environment value is rendered in client bundles
- transaction calldata/events contain only intended public values
- private notes/preferences do not become onchain state
- FIFO/tax/accounting records remain outside public protocol state
- provider requests do not include unrelated private application data
- sensitive error responses are redacted
- optional telemetry can be disabled without breaking core protocol use
- session authentication does not authorize blockchain transactions
- logout/session expiry invalidates optional-service credentials as designed
- private hosted data deletion/export behaves according to the service specification
- P5 transient values expire or are discarded as designed
- cross-chain features do not launch without a separate data/linkability review
- support/evidence tooling does not print P3 material
- static build artifacts contain no values classified as secret

## Frozen R7 invariants

1. Robinhood Chain public state, calldata, and events are treated as public.
2. Private application data is not placed onchain merely for convenience.
3. Hashing or encoding does not automatically make private data safe for public-chain publication.
4. Public wallet addresses are not assumed anonymous.
5. P0 public canonical data may be onchain when required by protocol design.
6. P1 public derived data is non-canonical and must retain appropriate provenance/freshness.
7. P2 private user/application data remains local or in an explicitly optional private service by default.
8. P3 credentials/signing material is prohibited from public Git, public frontend bundles, public chain state, public logs, and ordinary telemetry.
9. Core UTTchain does not custody user wallet private keys.
10. Existing UTT CEX credentials, private balances, FIFO/tax lots, and private notes remain outside UTTchain core.
11. UTT_PUBLISH is not a UTTchain runtime or private-data authority.
12. Events and calldata follow the same privacy classification as storage.
13. Logs, diagnostics, screenshots, and copy-back evidence are subject to data minimization.
14. Provider/oracle cryptographic validity does not make request metadata private.
15. Browser-local storage is not treated as a high-assurance secret store.
16. Optional telemetry is non-canonical and must not be required for core use.
17. Authentication data does not become transaction authorization.
18. Encryption does not by itself justify permanent publication of private data onchain.
19. P5 transient data should be discarded when its purpose ends unless explicitly reclassified.
20. New features require an explicit data-flow/classification review before implementation acceptance.
21. Cross-chain migration remains unauthorized and requires separate linkability/privacy review.
22. No new personal-data collection, hosted-service activation, deployment, migration, signing, broadcast, or mainnet action is authorized by this document.

## Current freeze status

This document freezes the initial privacy/data-classification architecture only.

It does not select:

- optional-service provider
- database technology
- encryption system
- analytics provider
- telemetry provider
- retention durations
- legal/compliance jurisdiction
- identity/KYC provider
- privacy-preserving blockchain technology
- cross-chain bridge
- UTTT canonical supply model
- exact contract interface
- mainnet parameter

Those require later evidence and explicit acceptance.

## Next architecture gate

UTTC.0.FINAL: reconcile and freeze the complete UTTC.0 architecture set.
