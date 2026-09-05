# UTTchain RPC, Oracle, and Indexer Trust Model

Status: UTTC.0.R6 draft/freeze candidate
Base chain: Robinhood Chain
Architecture boundary: UTTC.0.R2A
Threat model: UTTC.0.R3
Server-independent launch: UTTC.0.R4
Optional services and upgradeability: UTTC.0.R5A
R5 commit: 4436ecc98d5516254709670e68e7c9fb5c6e8c13
R5 blob: 25c3c64dd70a1baae33fc72c41d41d723c414dc8

## Purpose

This document freezes the trust boundary for Robinhood Chain RPC access, indexed/derived chain data, caches, and external oracle data used by UTTchain.

The objective is not to eliminate infrastructure. The objective is to ensure that infrastructure transports or accelerates verifiable facts without silently becoming canonical protocol authority.

This document does not authorize a provider contract, paid service, oracle feed, deployment, token migration, signing, broadcast, market activation, bridge activation, privileged-role assignment, or mainnet action.

## Current Robinhood Chain reference baseline

As of the R6 freeze, Robinhood Chain documentation identifies:

- mainnet chain ID: 4663
- testnet chain ID: 46630
- native gas token: ETH
- public mainnet RPC: https://rpc.mainnet.chain.robinhood.com
- public testnet RPC: https://rpc.testnet.chain.robinhood.com
- public endpoints as rate-limited and not recommended for production
- Alchemy as a recommended infrastructure provider, with additional provider options available
- Chainlink Data Streams as an available cryptographically signed external-data mechanism
- Robinhood Chain mainnet Data Streams Verifier Proxy: 0xcE73c8ad08CBDEaCa6078BF0627C8fe0a9a536E7

These values are reference evidence, not permanent protocol constants merely because they appear in this document.

Before deployment or activation, every network endpoint, verifier address, feed/report identity, and provider assumption must be revalidated against current authoritative documentation and onchain state.

No RPC, indexer, or oracle vendor is selected by R6.

## Canonicality hierarchy

For UTTchain, evidence authority is ordered by the nature of the claim rather than by provider branding.

For onchain protocol facts:

1. Robinhood Chain consensus and canonical state.
2. Contract runtime/state read at an explicitly identified chain and block.
3. Transaction/receipt/block evidence reconciled to canonical state.
4. Indexer or cache representation of that state.
5. Application-local cached or previously rendered data.

For externally originated data used by contracts:

1. The accepted contract verification rules.
2. A report satisfying the accepted cryptographic verifier/feed/report rules.
3. The data transported to the verifier.
4. Hosted dashboards, REST responses, caches, or UI representations.

A transport service cannot promote its own answer above the authority of the state or verification mechanism it is transporting.

## Provider categories

| Category | Primary use | Canonical authority? | Replaceable? |
| --- | --- | --- | --- |
| JSON-RPC endpoint | Chain reads, calls, estimates, transaction transport | No | Yes |
| WebSocket endpoint | Subscription/notification transport | No | Yes |
| Sequencer/feed endpoint | Low-latency observation where used | No | Yes |
| Block explorer/API | Human/external reconciliation aid | No | Yes |
| Indexer/Data API | History, search, balances, derived views | No | Yes |
| Browser cache | Latency reduction | No | Yes/discardable |
| Oracle delivery endpoint | Transport signed external reports | No by itself | Yes subject to accepted oracle mechanism |
| Onchain oracle verifier | Verify accepted signed reports | Yes only within the contract's accepted verification rules | Version/config controlled |
| UTTchain smart contract | Apply deterministic protocol rules | Yes after chain consensus | Per accepted module/evolution policy |

## RPC trust boundary

An RPC endpoint is an observation and transaction-transport interface to Robinhood Chain.

UTTchain must assume an endpoint can be:

- unavailable
- slow
- stale
- rate limited
- selectively censoring
- returning malformed data
- returning a valid response for the wrong chain
- inconsistent with another endpoint
- behind the canonical head
- temporarily inconsistent during reorganization or propagation
- compromised

The browser or deployment tooling must therefore validate the claim being made rather than treating endpoint success as proof.

## RPC identity checks

Before security-sensitive actions, the client or deployment gate must establish the intended network identity.

At minimum, as applicable:

- query and verify chain ID
- use exact contract addresses
- verify runtime code is present for contracts expected to exist
- verify expected code identity when the action depends on a frozen deployment
- bind reads/writes to the intended account and network
- reject silent network switching
- reject symbol/name-only identity
- do not reuse cached identity across an unverified chain change

Mainnet UTTchain operations must reject a chain ID other than the accepted Robinhood Chain mainnet chain ID.

Testnet state must never be interpreted as mainnet state merely because contract names or addresses resemble one another.

## RPC read classes

RPC reads are divided by consequence.

### Class R0 - display convenience

Examples:

- non-critical block-height display
- gas-price display
- exploratory metadata already labeled non-canonical

A single provider may be sufficient. Failure should render unavailable/stale rather than guessed.

### Class R1 - canonical state display

Examples:

- token balance
- allowance
- registry module address
- role/owner state
- protocol parameters

The response must be bound to the expected chain and exact contract identity. Critical UI state should preserve the block context where practical.

### Class R2 - transaction preparation

Examples:

- nonce
- allowance before approval
- protocol state used to build calldata
- quote-dependent onchain state
- simulation inputs
- estimated gas

The client must revalidate facts that can change materially before requesting signature. Stale cached values are not sufficient authority.

### Class R3 - financial reconciliation

Examples:

- whether a transaction was mined
- receipt status
- block inclusion
- resulting balance/state transition
- nonce consumption after an uncertain broadcast

R3 conclusions require canonical reconciliation and may use an independent second observation path when the first provider is unavailable, contradictory, or the outcome is financially ambiguous.

### Class R4 - deployment/upgrade acceptance

Examples:

- deployed address
- runtime bytecode
- implementation/proxy/admin state
- initialization state
- privileged roles
- critical supply/configuration invariants

R4 acceptance requires exact source/deployment evidence plus chain reconciliation. A provider response alone is not production acceptance.

## Block context

Security-sensitive reads should use an explicit block context where consistency matters.

The implementation must distinguish, as applicable:

- pending state
- latest observed state
- a specific block number/hash
- confirmed/finalized acceptance under the later production policy

A UI may render fast-moving latest state, but a multi-read invariant check should avoid silently combining unrelated block states when that can change the conclusion.

Where a provider or method does not support a desired block tag, the implementation must use a documented alternative rather than silently weakening the assumption.

## Provider disagreement

Provider disagreement is a security signal, not a reason to average values.

| Disagreement | Disposition |
| --- | --- |
| Chain ID differs | Fail closed |
| Expected contract code absent on one provider | HOLD and reconcile |
| Transaction found by one provider but absent on another | HOLD if outcome matters |
| Receipt status differs | HOLD and reconcile |
| Block height differs modestly | Classify lag; do not infer financial failure |
| Balance/state differs at different blocks | Re-read at an aligned block context |
| Same-block state differs | HOLD and investigate |
| Indexer differs from RPC state | Chain state wins for canonical facts |
| Cache differs from fresh canonical read | Invalidate cache |
| Oracle transport endpoints return different signed reports | Apply accepted verifier/feed/timestamp rules; do not average |

A second provider is useful only when it represents a meaningfully independent observation path. Two URLs backed by the same infrastructure should not automatically be treated as independent fault domains.

## RPC failover

Failover is permitted for availability.

Failover must not:

- change chain identity
- change accepted contract identity
- silently weaken finality/reconciliation rules
- convert a missing transaction into permission to rebroadcast
- reuse stale cached state as though it came from the replacement provider
- suppress a material disagreement

Provider rotation should preserve explicit observability in logs or diagnostics when operationally relevant.

## Transaction submission

For ordinary user actions, the wallet/provider path may submit the signed transaction.

Submission acknowledgement is not settlement acceptance.

The client must distinguish:

- signing requested
- signature produced
- submission attempted
- transaction hash observed
- transaction visible to one or more providers
- receipt observed
- receipt successful/failed
- canonical resulting state reconciled

If submission returns an error after the transaction may have been accepted, the action enters HOLD until nonce/transaction/receipt/state evidence establishes the outcome.

Automatic re-signing or rebroadcast under ambiguity is prohibited.

## Receipt and nonce reconciliation

A transaction hash is evidence of an intended transaction, not proof of canonical inclusion.

Reconciliation should use, as applicable:

- exact transaction hash
- sender
- nonce
- destination
- calldata/value
- receipt status
- inclusion block
- current/canonical transaction count
- expected resulting contract state

A missing receipt may mean pending, dropped, replaced, censored, provider-lagged, or never accepted. The client must not collapse these into a single "failed" state when a retry could duplicate financial authority.

## Indexer trust boundary

Indexers and Data APIs are derived-data systems.

They are suitable for:

- history
- event search
- pagination
- holder/activity views
- transaction discovery
- portfolio acceleration
- aggregate metrics
- application search

They are not canonical authority for:

- whether a contract exists
- runtime code identity
- current privileged roles
- canonical module identity
- current supply authority
- transaction success
- finalized settlement
- upgrade implementation/admin identity
- current allowance/balance when direct chain reads are feasible for the security decision

An indexer may discover evidence that is then verified against chain state.

## Indexer completeness and omission

UTTchain must assume an indexer can omit valid events or lag behind chain state.

Absence from an indexer is therefore not proof of absence from Robinhood Chain.

For an operation such as transaction reconciliation, external-swap ingestion, or holder/history display, the implementation should retain enough provenance to distinguish:

- indexed and verified
- indexed but not yet chain-reconciled
- directly chain-observed
- unavailable
- stale
- incomplete/unknown

An indexer must not manufacture a definitive zero/none state from incomplete coverage.

## Reorganizations and derived data

Derived systems can temporarily represent state that later changes.

Indexer/cache design must therefore define:

- block number/hash provenance where practical
- confirmation/finality policy for irreversible application conclusions
- reorg correction behavior
- idempotent re-ingestion
- duplicate suppression
- deletion/replacement of orphaned derived records where applicable

Canonical UTTchain contract state remains the ultimate authority after the accepted finality policy is satisfied.

## Cache policy

Caches are performance mechanisms only.

Every cache entry that can affect a financial or identity decision must have enough context to determine whether it is still valid, such as:

- chain ID
- contract/asset identity
- block or freshness context
- source/provider class
- timestamp where relevant
- version/schema
- explicit negative/no-route state when supported

A cached positive or negative result must not survive a context change that invalidates its assumptions.

Cache corruption or loss must degrade performance, not alter canonical protocol state.

## Oracle trust boundary

Oracle data differs from ordinary indexed chain data because a protocol may intentionally use verified offchain-originated facts.

UTTchain must separate:

1. report transport
2. report authenticity
3. feed/report identity
4. freshness
5. unit/decimal interpretation
6. bounds/sanity
7. contract authorization
8. state transition using the verified value

A successful HTTP response satisfies only transport.

## Chainlink Data Streams reference

Robinhood Chain currently documents Chainlink Data Streams as an available pull-based, cryptographically signed oracle mechanism.

For Robinhood Chain mainnet, the currently documented Data Streams Verifier Proxy is:

0xcE73c8ad08CBDEaCa6078BF0627C8fe0a9a536E7

R6 does not select Data Streams for a UTTchain module and does not select any feed.

If a later component proposes Data Streams, its acceptance must independently revalidate the current verifier address and exact integration requirements before deployment.

## Oracle acceptance envelope

Before an oracle-dependent state transition can be implemented, the component specification must freeze:

- exact oracle mechanism
- network/chain ID
- verifier contract identity
- feed/report identifier
- signer/verification assumptions
- report schema/version
- price/value units
- decimals/scaling
- source timestamp semantics
- observation/publication timestamp semantics where provided
- maximum age
- future-timestamp tolerance
- zero/negative/invalid-value behavior
- min/max or economic sanity bounds where appropriate
- sequencer/network outage assumptions where applicable
- replay protection
- duplicate-report behavior
- fallback behavior
- verifier/configuration upgrade behavior
- events/evidence needed for reconciliation

No generic "oracle price" variable is accepted without this envelope.

## Oracle freshness

Freshness must be enforced by the layer with protocol authority.

If stale data can cause an invalid onchain transition, freshness validation belongs in the contract or in a cryptographically enforced mechanism that the contract verifies.

A browser warning alone is not sufficient to protect an onchain state transition from a stale-but-validly-signed report.

If a report is too old, too far in the future, malformed, for the wrong feed, for the wrong verifier/domain, or outside accepted bounds, the dependent transition must fail closed.

## Oracle fallback

Fallback must be explicit.

Permitted designs may include:

- reject the oracle-dependent action while the feed is unavailable
- use a separately reviewed secondary mechanism with explicit precedence
- allow a non-oracle protocol path that does not depend on the missing value

Prohibited fallback includes:

- silently using a hosted unsigned REST price
- silently using a stale cached price
- averaging incompatible feeds
- changing units/decimals without a versioned rule
- allowing an optional service operator to supply an arbitrary substitute value

Availability pressure does not justify converting unverified data into canonical authority.

## Oracle delivery and privacy

Pull-based oracle transport may involve requests to external services before onchain verification.

The later privacy classification must assess what request metadata can reveal about users or intended actions.

R6 freezes only that oracle transport endpoints are external infrastructure and that cryptographic verification does not make transport metadata private.

## Browser/provider configuration

The browser may ship with default provider configuration, but defaults are not canonical identity.

Configuration should separate:

- canonical chain constants/registry identities
- default transport endpoints
- optional API credentials
- feature flags
- indexer endpoints
- oracle transport endpoints

Changing an RPC URL must not change canonical contract identity.

Changing a hosted configuration response must not silently change privileged addresses, supply authority, or accepted implementation identity.

## Secrets and provider keys

Provider API keys intended to remain secret must not be embedded in public static frontend bundles.

A browser-facing endpoint must be treated as public unless the provider explicitly supports a safe public-client credential model.

If a private key/API credential is required for an optional service, it belongs in that service's scoped secret boundary, not in public Git or onchain state.

This is a credential-placement rule, not a selection of any provider.

## Availability and degradation

| Failure | Required behavior |
| --- | --- |
| Primary RPC unavailable | Fail over or report unavailable |
| All RPCs unavailable | Disable chain-dependent actions; do not invent state |
| RPC lagging | Mark/reconcile according to consequence class |
| RPC disagreement | HOLD security-critical conclusion |
| Indexer unavailable | Degrade history/search; preserve direct reads where feasible |
| Indexer incomplete | Mark unknown/incomplete; do not assert zero/absence |
| Cache unavailable | Recompute/refetch |
| Cache stale | Invalidate/revalidate |
| Oracle transport unavailable | Reject/defer oracle-dependent action unless explicit reviewed fallback exists |
| Oracle report stale/invalid | Fail closed |
| Verifier identity uncertain | Fail closed |
| Provider API key exhausted | Degrade/fail over; no authority change |
| Optional service unavailable | Core onchain/browser path remains independent |

## Monitoring

Monitoring may observe:

- RPC latency/error rate
- head lag
- provider disagreement
- indexer lag
- cache error rate
- oracle transport availability
- oracle verification failures
- stale-report rejection
- chain reorganization indicators
- transaction reconciliation latency

Monitoring is operational evidence. It does not itself authorize protocol mutation.

Alerts may recommend operator/user action but must not silently bypass the accepted signing or governance boundary.

## Provider/configuration changes

Changing an RPC/indexer/oracle transport provider is an infrastructure configuration change, not automatically a contract upgrade.

However, a change that alters any canonical trust assumption is a protocol/security change and requires the corresponding acceptance gate.

Examples include:

- changing an onchain verifier
- changing an accepted feed/report identity
- changing freshness limits
- changing oracle units/scaling
- changing a privileged configuration role
- making an indexer newly mandatory for core correctness
- changing finality assumptions

The classification depends on authority, not on whether the edit occurs in a config file.

## Test requirements

Later implementation acceptance must test, as applicable:

- wrong chain ID is rejected
- wrong contract address/code is rejected
- stale RPC response cannot override aligned canonical evidence
- provider replacement preserves contract identity
- same-block provider disagreement produces HOLD
- missing receipt does not trigger automatic duplicate financial action
- nonce/replacement ambiguity is reconciled
- indexer omission does not prove chain absence
- stale indexer data is marked/degraded
- cache invalidation occurs on chain/context/version change
- corrupted cache does not change canonical state
- wrong oracle verifier is rejected
- wrong feed/report identifier is rejected
- stale oracle report is rejected
- future-dated report outside tolerance is rejected
- unit/decimal mismatch is rejected
- invalid or out-of-bounds oracle value is rejected
- unavailable oracle does not silently fall back to unsigned hosted data
- optional provider/service outage does not create signing authority
- deployment/upgrade reconciliation survives primary-provider failure

## Frozen R6 invariants

1. Robinhood Chain consensus and contract state, not an RPC vendor, determine canonical onchain facts.
2. Mainnet and testnet identity must be explicitly separated by chain ID and accepted contract identity.
3. RPC endpoints are replaceable transport and may be faulty or adversarial.
4. Provider success is not transaction settlement acceptance.
5. Financial ambiguity enters HOLD until transaction/nonce/receipt/state reconciliation establishes the outcome.
6. Automatic financial retry under uncertain authority remains prohibited.
7. Provider disagreement is never resolved by averaging canonical state.
8. Indexers are derived and may be stale or incomplete.
9. Indexer absence is not proof of chain absence.
10. Caches are discardable performance state and cannot become canonical authority.
11. Oracle transport success does not establish report authenticity or protocol validity.
12. Oracle-dependent transitions require exact verifier/feed/schema/freshness/unit/bounds rules.
13. Stale, wrong-domain, wrong-feed, malformed, or otherwise invalid oracle reports fail closed.
14. Unsigned hosted data is not an implicit oracle fallback.
15. No single RPC/indexer vendor is frozen by this architecture.
16. Chainlink Data Streams is a currently available Robinhood Chain mechanism, not an R6 provider/feed selection.
17. Provider secrets that must remain private are prohibited from public frontend bundles and Git.
18. Provider/configuration changes that alter canonical trust assumptions require protocol/security acceptance.
19. Optional infrastructure outage must not silently create new protocol authority.
20. No provider contract, oracle feed, deployment, migration, signing, broadcast, or mainnet action is authorized by this document.

## Current freeze status

This document freezes the RPC/oracle/indexer trust model only.

It does not select:

- production RPC vendor
- production indexer
- oracle mechanism for a UTTchain component
- oracle feed/report identity
- oracle freshness interval
- oracle bounds
- provider API plan
- static hosting provider
- governance authority
- bridge mechanism
- UTTT canonical supply model
- exact contract interface
- mainnet deployment parameter

Those require later evidence and explicit acceptance.

## Next architecture gates

UTTC.0.R7: privacy and data classification.
UTTC.0.FINAL: architecture freeze.
