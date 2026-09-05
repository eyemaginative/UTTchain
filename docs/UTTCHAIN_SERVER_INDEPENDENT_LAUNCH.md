# UTTchain Server-Independent Launch Specification

Status: UTTC.0.R4 draft/freeze candidate
Base chain: Robinhood Chain
Architecture boundary: UTTC.0.R2A
Threat model: UTTC.0.R3
Threat-model commit: 7a5f7cc85176070b6d55ffcdcf9f300e5c680454
Threat-model blob: 5de0f1294f79f36621de80f6d916adfd7f009955

## Purpose

This document freezes the server-independent launch architecture for UTTchain.

Server-independent means that core UTTchain use does not require a project-operated application server, a user-operated localhost daemon, a companion machine, or the existing UTT terminal to remain online.

It does not mean that all network infrastructure disappears. A browser still requires access to Robinhood Chain through one or more RPC paths, and some features may require replaceable oracle or indexer infrastructure. Static web assets also require a delivery mechanism unless the client is distributed another way.

This document does not authorize deployment, token migration, signing, broadcast, market activation, bridge activation, or mainnet action.

## Launch invariant

The canonical launch path is:

static/browser client
+ user wallet
+ Robinhood Chain
+ replaceable RPC infrastructure
+ narrowly scoped oracle/indexer infrastructure only where required

The existing local UTT may integrate with this path but is not required for core UTTchain availability.

A project-operated application API is not a launch dependency.

## Definition of core

For this specification, core means the minimum set of functions required to identify, inspect, authorize, and interact with canonical UTTchain protocol state.

Core includes, where implemented:

- canonical network and contract identity
- registry and module/version discovery
- chain-state reads
- wallet connection
- transaction construction
- user-visible transaction review
- simulation where available
- wallet-authorized transaction submission
- receipt and canonical-state reconciliation
- finite approval flows where required
- deterministic protocol settlement
- public protocol metadata derived from canonical records

A feature is not core merely because it is useful in the existing UTT terminal.

## Explicitly non-core launch functions

The following do not become launch dependencies:

- CEX exchange adapters
- CEX API credentials
- CEX order routing or submission
- local SQLite persistence
- FIFO lot accounting
- tax-basis accounting
- background terminal workers
- private notes or strategy data
- project-hosted user sessions
- notifications
- hosted analytics
- hosted automation
- UTT_PUBLISH
- the existing UTT backend
- a mandatory indexer for facts that can be read directly from chain
- a mandatory custom relay for ordinary user-signed transactions

These capabilities may remain in existing UTT or be added later through optional services, subject to separate security review.

## Runtime dependency classes

| Dependency | Launch role | Mandatory? | Authority |
| --- | --- | --- | --- |
| Robinhood Chain | Canonical execution/state | Yes | Canonical protocol authority after consensus |
| User wallet | User authorization/signing | Yes for state-changing user actions | User transaction authority |
| Browser/static client | User interface and transaction construction | Yes for the web launch surface | Untrusted client; no canonical state authority |
| RPC provider | Chain transport/read/send path | Yes as a category; no single provider mandatory | Non-canonical transport |
| Indexer | History/search/derived acceleration | No unless a later feature proves technically unavoidable | Derived/non-canonical |
| Oracle/verifier path | External data only when a protocol function requires it | Feature-specific | Canonical only after reviewed verification rules |
| Static asset host/CDN | Client delivery | Yes for hosted web distribution; replaceable | No protocol authority |
| Project application server | Optional post-launch extension | No | Non-canonical by default |
| Existing UTT | Optional integration/application | No | Separate application authority |
| UTT_PUBLISH | Existing UTT release workspace | No | No UTTchain runtime authority |

## Static client delivery

A static site, CDN, object store, repository-hosted site, or equivalent may distribute browser assets.

Static delivery is not the same as a mandatory application server.

The delivery layer must not become canonical authority for contract addresses, network identity, supply, balances, settlement state, or user authorization.

Where practical, canonical addresses and versions should be independently recoverable from onchain registry/deployment records and release artifacts so a compromised or stale client can be detected.

The client should be mirrorable and replaceable without changing protocol state.

## Browser responsibilities

The browser client may:

- discover configured and onchain identities
- read chain state through RPC
- read derived data through optional indexers
- retrieve and verify externally signed reports where applicable
- construct calldata and transaction requests
- calculate user-visible bounds
- request simulation
- compare expected and observed state
- request wallet signatures
- submit signed transactions through wallet/provider interfaces
- reconcile transaction receipts and resulting chain state
- render protocol state and warnings

The browser must not:

- retain user private keys or seed phrases
- silently sign on behalf of the user
- treat local cache as canonical state
- treat a single RPC/indexer response as unquestioned truth
- invent balances, prices, receipts, or transaction success
- hide approval spender/amount
- silently switch chain or contract identity
- retry uncertain financial actions before reconciliation

## Wallet responsibilities

The wallet is the core user signing boundary.

For a state-changing action, the client must present sufficient information for the user to distinguish the intended action from a materially different one.

The integration must bind, as applicable:

- connected account
- chain ID
- transaction destination
- function/action
- ETH value
- token address
- token amount
- spender
- approval amount
- slippage or min/max execution bound
- deadline/expiry
- nonce/domain data for signatures
- expected state transition

UTTchain infrastructure must not require custody of a user's signing key for ordinary core use.

## RPC requirements

UTTchain requires RPC access as a transport category but must not require one irreplaceable provider.

The client architecture should support provider replacement without changing canonical contract state.

For security-critical reads, the implementation must use controls appropriate to the action, including:

- expected chain ID
- expected contract address
- runtime code presence/identity where relevant
- explicit block/finality assumptions
- receipt status and transaction identity
- canonical-state reconciliation
- timeout classification
- provider disagreement handling
- no automatic financial retry after ambiguity

Provider failure is an availability problem unless and until canonical state is uncertain. It must not be converted into fabricated success or fabricated protocol state.

## Indexer requirements

An indexer is optional by default.

Indexers may accelerate:

- historical events
- holder/activity views
- search
- pagination
- aggregate display
- derived metrics

An indexer must not be the sole authority for:

- current canonical balances where direct chain reads are feasible
- contract identity
- transaction success
- finalized settlement state
- supply authority
- privileged-role state
- upgrade state

If a future core function genuinely cannot operate without indexed history, that exception requires a separate acceptance explaining why direct/onchain alternatives are insufficient and how the indexer remains replaceable and reconcilable.

## Oracle requirements

Oracle infrastructure is feature-specific rather than a blanket launch dependency.

No unsigned HTTP price or hosted calculation may directly establish canonical onchain state.

If a contract consumes external data, the architecture must define and test:

- report/feed identity
- verifier identity
- network/chain identity
- signer or verification assumptions
- freshness and timestamp semantics
- decimals and unit normalization
- acceptable bounds
- stale/invalid behavior
- fallback behavior
- outage behavior
- upgrade/version behavior

The contract should verify the minimum data required for its function rather than trust a project application server to attest arbitrary values.

## Transaction path

The preferred ordinary state-changing path is:

1. Browser obtains canonical identities and current state.
2. Browser constructs the intended transaction.
3. Browser validates chain, target, value, token/spender, and bounds.
4. Browser simulates when a reliable simulation path is available.
5. Browser presents the action to the wallet.
6. User explicitly authorizes/signs in the wallet.
7. Wallet/provider broadcasts the signed transaction.
8. Client observes transaction and receipt state.
9. Client reconciles the resulting canonical chain state.
10. If outcome is uncertain, the action enters HOLD rather than being automatically retried.

A custom backend relay is not required for this ordinary path.

## Read path

The preferred read path is:

1. Resolve exact chain and contract identity.
2. Read canonical state from Robinhood Chain through an RPC provider.
3. Use indexer/cache data only as derived acceleration.
4. Compare critical derived claims to chain state where warranted.
5. Render an explicit unavailable/stale state when required data cannot be established.

The client must not convert missing information into guessed financial data.

## Failure and degradation model

| Failure | Required behavior |
| --- | --- |
| Static host unavailable | Use another mirror/distribution path when available; protocol state remains unaffected |
| Primary RPC unavailable | Fail over or report unavailable |
| RPC providers disagree | HOLD security-critical conclusions until reconciled |
| Indexer unavailable | Degrade history/search; retain direct chain functions where feasible |
| Indexer stale | Mark derived view stale and reconcile critical facts to chain |
| Oracle unavailable/stale | Reject oracle-dependent state transition according to policy |
| Optional service unavailable | Core launch path remains usable |
| Existing UTT offline | Core UTTchain path remains usable |
| UTT_PUBLISH unavailable | No UTTchain runtime effect |
| Wallet unavailable | Read-only functions may remain; user-signed state changes unavailable |
| Browser cache corrupt | Discard/rebuild; do not override canonical chain state |
| Transaction timeout/ambiguity | HOLD and reconcile; no automatic retry |

## No mandatory localhost boundary

UTTchain must not require users to install or continuously run:

- a localhost API
- a Python daemon
- a Node daemon
- a database service
- a background worker
- the existing UTT backend
- a signing bridge
- a companion desktop agent
- a second always-on machine

Developer tooling such as Foundry, local test nodes, scripts, and build commands is permitted for development and deployment operations. It is not an end-user runtime requirement.

## No mandatory project application server

The project may operate websites, static hosting, RPC relationships, indexers, or optional services, but core correctness must not depend on a private project database or application API being online.

If a future feature requires a hosted service, that feature must be labeled optional unless a later architecture tranche explicitly reclassifies it with justification. A service cannot become core merely through implementation convenience.

## Optional service integration rule

A future optional service may improve convenience or add capabilities, but it must have an explicit boundary covering:

- inputs and outputs
- data sensitivity
- credentials
- authentication
- authority
- signing capability
- persistence
- failure behavior
- replacement/migration
- canonical reconciliation
- deletion/recovery where applicable

Optional services are non-canonical by default.

## Existing UTT integration

The existing Unified Trading Terminal remains a separate application.

UTT may later:

- display UTTchain state
- use canonical UTTchain registry data
- construct compatible browser/wallet actions
- reconcile onchain executions
- retain CEX functionality
- retain local portfolio/accounting functionality

Such integration must not cause UTTchain to require the local UTT process for core launch functions.

UTT CEX credentials, accounting databases, background processes, and tax records remain outside UTTchain core.

UTT_PUBLISH remains the existing UTT publication/reconciliation workspace and has no UTTchain runtime role.

## Deployment architecture

Development and deployment may use local engineering tools, but production acceptance remains source- and chain-reconciled.

A deployment pipeline may use Foundry and other reviewed tools to build, simulate, test, and broadcast only under an explicit deployment authorization gate.

Deployment tooling is not a persistent protocol runtime dependency.

No production deploy may rely on uncommitted source.

No mainnet broadcast is authorized by this document.

## Upgrade and module evolution

Server independence does not require every contract to be immutable, and optional hosting does not justify blanket proxies.

Evolution should prefer:

1. client/service improvements that do not alter canonical contracts
2. new versioned modules
3. explicit migration/supersession where safe
4. component-specific proxy upgrades only where justified

Any upgradeable component requires the separate controls already frozen by the threat model and later UTTC.0.R5 work.

## Acceptance tests for server independence

Before a launch architecture can be accepted, testing must demonstrate that core functions do not secretly depend on a localhost or project application server.

The later implementation test plan must include, as applicable:

- client loads from a static distribution
- wallet connection without local UTT
- chain identity resolution without local UTT
- contract-state reads without local UTT
- transaction construction without local UTT
- wallet signing without local UTT
- transaction submission without local UTT
- receipt/state reconciliation without local UTT
- optional service disabled
- indexer disabled for direct-read-capable core functions
- primary RPC replaced by another compatible provider
- stale cache discarded
- unavailable data rendered unavailable rather than guessed

A failure of these tests is an architecture regression, not merely an operational inconvenience.

## Frozen launch invariants

1. Core launch use does not require the existing UTT process.
2. Core launch use does not require UTT_PUBLISH.
3. Core launch use does not require a localhost daemon.
4. Core launch use does not require a project application API.
5. Static asset delivery is replaceable and non-canonical.
6. RPC is required as a category, not as one irreplaceable provider.
7. Indexers are optional by default and derived/non-canonical.
8. Oracle dependencies are feature-specific and explicitly verified.
9. User signing remains in the wallet.
10. Canonical protocol state remains on Robinhood Chain.
11. Missing provider data is never replaced with invented financial state.
12. Uncertain financial actions enter HOLD pending reconciliation.
13. Existing UTT CEX/accounting systems remain separate.
14. Optional hosted services remain additive and non-canonical by default.
15. Developer/build/deployment tooling is not an end-user runtime dependency.
16. No mainnet action is authorized by this specification.

## Current freeze status

This document freezes the server-independent launch architecture only.

It does not select an RPC vendor, indexer vendor, oracle feed, static host, optional-service provider, governance authority, proxy pattern, bridge, exact contract interface, UTTT canonical supply model, or mainnet parameters.

## Next architecture gates

UTTC.0.R5: optional service and upgradeability boundary.
UTTC.0.R6: RPC/oracle/indexer trust model.
UTTC.0.R7: privacy and data classification.
UTTC.0.FINAL: architecture freeze.
