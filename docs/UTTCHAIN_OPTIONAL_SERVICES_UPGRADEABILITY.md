# UTTchain Optional Service and Upgradeability Boundary

Status: UTTC.0.R5 draft/freeze candidate
Base chain: Robinhood Chain
Architecture boundary: UTTC.0.R2A
Threat model: UTTC.0.R3
Server-independent launch: UTTC.0.R4
Server-independent launch commit: 46290655fce06796e4e60e719814f6af3a720a52
Server-independent launch blob: 6c0e06528dfde7a6656c0e51f43b41dc046c7576

## Purpose

This document freezes the boundary for optional hosted/serverless services and for contract upgradeability in UTTchain.

The objectives are:

1. Preserve the server-independent core launch architecture.
2. Permit useful hosted capabilities later without allowing them to become silent protocol authority.
3. Permit protocol evolution without requiring blanket proxy control.
4. Define when immutability, versioned modules, explicit migration, or a proxy may be appropriate.
5. Bound administrative authority and make every privileged capability observable and reviewable.

This document does not authorize deployment, token migration, signing, broadcast, market activation, bridge activation, proxy deployment, privileged-role assignment, or mainnet action.

## Relationship to prior freezes

UTTC.0.R2A established that canonical deterministic protocol state belongs on Robinhood Chain, user signing belongs in the browser wallet, external data infrastructure is replaceable, optional services are non-canonical by default, and the existing UTT remains a separate application boundary.

UTTC.0.R3 established that optional services, browser state, RPC/indexer responses, and deployment infrastructure may be compromised and therefore cannot be treated as automatically trustworthy.

UTTC.0.R4 established that core launch use must remain functional without a localhost daemon, the existing UTT backend, UTT_PUBLISH, or a mandatory project application API.

R5 adds a governance and evolution boundary to those freezes.

## Optional service principle

An optional service is an additive capability outside the canonical core protocol path.

Its existence must not silently change the answer to any of the following questions:

- What is the canonical UTTchain contract or module?
- What is the canonical onchain state?
- Did a transaction succeed?
- What authority does a user grant?
- Who can change protocol code or privileged state?
- What is the canonical UTTT supply or representation?
- Is a user-signed action valid?

Unless a later accepted architecture change explicitly says otherwise, those questions are answered by chain state, wallet authority, reviewed contract rules, and accepted deployment records rather than by a private service database.

## Permitted optional service classes

Optional hosted or serverless services may provide:

- caching of public chain data
- indexed history and search
- derived analytics
- notifications
- public metadata acceleration
- private user preferences
- private notes or application state
- authenticated user convenience features
- separately authorized CEX integrations
- automation that remains within an explicitly bounded authority grant
- rate limiting and abuse protection for service-owned endpoints
- static asset delivery
- monitoring and operational telemetry
- non-canonical quote aggregation
- developer/operator observability

These capabilities remain subject to privacy, credential, signing, and canonical-reconciliation rules.

## Optional service authority ceilings

| Service capability | Allowed authority | Prohibited authority |
| --- | --- | --- |
| Public cache | Return cached/derived public data | Override canonical chain state |
| Indexer/search | Accelerate history/search | Establish settlement or transaction success |
| Analytics | Produce derived metrics | Invent balances or canonical financial state |
| Notifications | Alert on observed conditions | Cause hidden financial action |
| Private preferences | Store user-selected settings | Become protocol identity authority |
| Private notes | Store user-private content | Publish private content onchain by default |
| Auth/session layer | Authenticate access to optional features | Become required for core wallet/onchain use |
| CEX integration | Act only under separately scoped user credentials/authority | Become mandatory UTTchain core infrastructure |
| Automation | Perform only explicitly bounded actions | Acquire unlimited/general signing authority |
| Static host/CDN | Deliver client assets | Become canonical contract/address authority |
| Monitoring | Observe service/protocol health | Mutate protocol state without explicit authority |
| Quote service | Return non-canonical quote candidates | Assert execution or settlement success |

## Service authentication

Optional service authentication must remain separate from blockchain transaction authorization.

A hosted session may use a wallet-signature login or another reviewed authentication mechanism, but login authentication does not itself authorize an onchain transfer, approval, protocol mutation, or CEX order.

If wallet signatures are used for authentication, the signed message must use explicit domain separation, nonce/replay protection, expiration where appropriate, and a human-readable statement of purpose.

A transaction must not be required merely to establish an ordinary web session.

## Service credential boundary

Service credentials must be scoped to the minimum capability required.

Examples include:

- service API keys
- encrypted CEX credentials
- notification-provider tokens
- database credentials
- observability tokens

Such credentials must not be committed to Git, embedded in static frontend bundles, written to public chain state, or exposed in logs.

Where an optional service holds a credential that can cause a financial action, its authority model requires a separate security review and explicit user authorization semantics.

## Signing boundary

The default optional-service signing rule is:

NO GENERAL USER SIGNING AUTHORITY.

A hosted service must not silently become the signer for ordinary UTTchain core actions.

If a future feature introduces delegated authority, session keys, smart-account permissions, relayers, or automation, the grant must be explicitly bounded by parameters such as:

- account
- chain
- target contract
- function/action
- asset
- maximum amount
- approval/spender scope
- frequency or cumulative limit
- start/expiry time
- nonce/replay domain
- revocation path

The authority must be observable and independently revocable according to the design.

## Service failure rule

Failure of an optional service must not corrupt canonical protocol state.

For a capability that was previously server-independent, an optional-service outage must not make that capability permanently dependent on the service.

Acceptable degradation includes:

- loss of cached acceleration
- loss of search/indexed history
- delayed notifications
- loss of optional analytics
- loss of private hosted preferences
- loss of optional CEX integration

Unacceptable degradation includes:

- inability to identify canonical contracts solely because the service is offline
- inability to reconcile onchain settlement solely because the service is offline when direct chain reads suffice
- hidden substitution of stale hosted state for canonical state
- automatic financial retry because a service timed out

## Replaceability and exit

An optional service should be replaceable without changing canonical protocol state.

Where practical, service design should define:

- portable or reconstructible public data
- export/deletion semantics for private user data
- credential revocation
- provider replacement
- cache invalidation
- canonical-chain reconciliation after migration
- behavior while two providers disagree
- end-of-service behavior

Service shutdown must not create a new protocol owner or freeze canonical state by accident.

## Data ownership and privacy

Optional services may hold data that should never be public onchain.

Examples include:

- CEX credentials
- private portfolio aggregation
- tax basis and FIFO lots
- private notes
- user preferences
- strategy data
- private alert rules
- service authentication/session data

The later UTTC.0.R7 privacy classification remains authoritative for detailed handling. R5 freezes only that optional hosting does not justify publishing private data or making the service canonical.

## Existing UTT boundary

The existing Unified Trading Terminal remains separate from UTTchain core.

UTT may integrate with optional UTTchain services or directly with onchain modules, but:

- UTT is not a required launch dependency
- UTT_PUBLISH is not a UTTchain runtime component
- UTT CEX credentials remain outside public chain state
- UTT local accounting remains separate from canonical protocol state
- UTT background workers do not become protocol consensus
- UTT must not silently inherit privileged UTTchain upgrade authority

## Contract evolution hierarchy

UTTchain uses the following preferred order for protocol evolution:

1. Browser/client or optional-service changes that do not alter canonical contracts.
2. New immutable or versioned contracts/modules registered alongside prior versions.
3. Explicit migration or supersession from an older module to a newer module.
4. Component-specific proxy or upgrade mechanism only when a demonstrated requirement justifies it.

This order is a design preference, not a claim that every component must be immutable.

## Immutability preference

Immutability is preferred when:

- the rules are small and stable
- the component holds critical supply or identity invariants
- migration can be explicit and safe
- upgrade authority would create disproportionate systemic risk
- versioned deployment can provide evolution without mutating existing code

Critical token/supply authority must not become upgradeable merely for implementation convenience.

## Versioned module preference

Versioned modules are preferred when protocol functionality can evolve while preserving old state or interfaces.

A versioned-module model should define:

- unique module/version identity
- registry discovery
- activation/deprecation state
- compatibility expectations
- migration path if state must move
- whether old versions remain callable
- how the browser chooses the accepted version
- events or records that make version changes externally visible

A frontend configuration file alone is insufficient authority for canonical module replacement.

## Proxy eligibility test

A proxy or equivalent upgrade mechanism may be considered only when all of the following are answered:

1. What concrete requirement cannot be met adequately by immutable/versioned deployment?
2. What exact state must persist across code upgrades?
3. What authority performs the upgrade?
4. Can that authority move funds, change supply, or bypass user permissions?
5. Is a multisig and/or timelock required?
6. What is the storage-layout discipline?
7. How is initialization protected?
8. How are implementation and proxy addresses recorded?
9. How are upgrades announced and observed?
10. What tests prove old state remains valid?
11. What happens if an upgrade is defective?
12. Can users exit or migrate?
13. What emergency powers exist?
14. What happens if the upgrade authority is compromised?
15. How is source-to-runtime code reconciliation performed?

If these answers are not explicit and accepted, the component is not ready for proxy-based upgradeability.

## Prohibited upgrade patterns

The following are rejected:

- blanket proxying of every contract
- a single omnipotent upgrade key for unrelated components without demonstrated need
- hidden or undocumented implementation replacement
- uninitialized or re-initializable proxy deployments
- upgrade authority embedded only in frontend configuration
- upgrade execution from uncommitted source
- storage-layout changes without review and tests
- upgrades that silently add mint, confiscation, transfer, or arbitrary call authority
- upgrade paths that bypass frozen supply or identity constraints
- automatic emergency upgrades without explicit authority and evidence
- treating a successful upgrade transaction as sufficient acceptance without runtime/state reconciliation

## Privileged-role model

Every privileged role must be component-specific and least-privilege.

Before a role is accepted, documentation must state:

- role name
- controlling address/account type
- exact callable functions
- whether it can move funds
- whether it can change supply
- whether it can change code
- whether it can pause/unpause
- whether it can change oracle/provider/verifier configuration
- whether it can change registry identity
- transfer/renunciation procedure
- multisig requirement
- timelock requirement
- emitted events
- compromise consequence
- recovery or replacement procedure

An undocumented role is not accepted production authority.

## Multisig and timelock policy

R5 does not select exact governance signers or thresholds.

Where privileged authority can materially change code, funds, supply, or critical configuration, the later component design must evaluate multisig control.

Where an upgrade or configuration change can materially alter user trust assumptions, the later design must evaluate a timelock or other notice window.

Emergency controls may justify a different delay profile, but emergency authority must be narrower than routine governance where practical.

## Emergency controls

Pause or emergency mechanisms are not mandatory merely because they are common.

If introduced, they must define:

- trigger conditions
- authorized caller
- exact functions affected
- whether withdrawals/exits remain available
- maximum or expected duration
- event visibility
- unpause/recovery procedure
- interaction with upgrade authority
- consequences of a compromised emergency key

Emergency authority must not be a disguised permanent superuser.

## Storage and initialization safety

For any upgradeable component:

- storage layout must be explicitly tracked
- incompatible layout changes must be rejected
- initialization must be one-time and protected
- implementation contracts should be protected against unintended initialization where applicable
- upgrade tests must cover preserved state
- new variables/defaults must be reviewed
- delegatecall-related authority must be understood
- proxy/admin/implementation identities must be reconciled after deployment and upgrade

## Upgrade execution lifecycle

A production upgrade, if one is eventually authorized, must follow a gated lifecycle:

1. Accepted requirement and component-specific justification.
2. Accepted source and exact commit.
3. Dependency/compiler/toolchain freeze.
4. Unit, invariant, fuzz, and upgrade-path tests as applicable.
5. Storage-layout review where applicable.
6. Static/security analysis.
7. Fork/read-only or testnet validation where applicable.
8. Explicit governance/admin authorization.
9. Transaction construction and simulation.
10. Explicit broadcast authorization.
11. Receipt reconciliation.
12. Runtime implementation/code identity verification.
13. Proxy/admin/implementation state verification.
14. Critical state/invariant verification.
15. Version/event/registry reconciliation.
16. Final production acceptance.

No step is implied merely by completion of an earlier step.

## Rollback and supersession

"Rollback" must not be promised unless the component actually supports a safe rollback model.

Depending on the component, recovery may instead require:

- another reviewed upgrade
- pausing a narrow function
- deploying a corrected new version
- migrating to a superseding module
- user-directed exit

If state migration is irreversible, that fact must be explicit before activation.

A rollback mechanism that itself creates an unrestricted upgrade backdoor is not automatically safer.

## Registry and version visibility

UTTchain should make component identity and version changes externally discoverable.

Where applicable, the design should expose:

- canonical module identifier
- version
- implementation address
- proxy address if used
- activation/deprecation state
- upgrade or migration event
- relevant code/runtime identity evidence

The browser may cache these values, but canonical identity must not exist solely in a project-operated service.

## Service and upgrade interaction

An optional service must not become an undisclosed upgrade control plane.

Examples of prohibited coupling include:

- service database flag silently selecting a new canonical implementation
- hosted API response changing privileged addresses without onchain authorization
- service possession of an upgrade key merely for operational convenience
- service outage preventing users from discovering the actual onchain implementation

If a service helps prepare governance or upgrade transactions, final authority must remain with the explicitly accepted onchain/admin control path.

## Test requirements

Later implementation acceptance must include tests that prove, as applicable:

- core behavior survives optional-service outage
- direct chain identity remains recoverable without the service
- optional-service cache cannot override canonical state
- optional-service authentication does not authorize a transaction by itself
- delegated authority is bounded and revocable if introduced
- immutable modules have no hidden upgrade path
- upgradeable modules reject unauthorized upgrades
- initialization cannot be replayed
- storage remains valid across upgrades
- upgrade events/version identity are observable
- old and new module behavior is reconciled during migration
- emergency authority is bounded
- critical supply invariants survive every authorized transition

## Frozen R5 invariants

1. Optional hosted/serverless services are non-canonical by default.
2. Core launch functionality remains independent of optional services.
3. Optional-service authentication is not transaction authorization.
4. Optional services do not receive general user signing authority.
5. Delegated authority, if introduced, must be explicitly bounded and revocable.
6. Optional-service failure must not corrupt canonical protocol state.
7. Optional services must not silently replace chain-derived identity or settlement state.
8. Existing UTT and UTT_PUBLISH remain outside UTTchain core runtime authority.
9. Protocol evolution prefers client/service changes, versioned modules, and explicit migration before proxies.
10. Blanket proxy architecture is rejected.
11. Proxy use requires component-specific justification.
12. Every privileged role must be explicit, narrow, observable, and documented.
13. Critical UTTT supply authority must not be upgradeable merely for convenience.
14. Storage layout and initialization safety are mandatory for upgradeable components.
15. Production upgrades require source-to-runtime and state reconciliation.
16. A successful upgrade transaction alone is not production acceptance.
17. Optional services must not become an undisclosed upgrade control plane.
18. No proxy deployment, privileged-role assignment, or mainnet action is authorized by this document.

## Current freeze status

This document freezes the optional-service and upgradeability boundary only.

It does not select:

- an optional-service provider
- service database technology
- service authentication provider
- exact governance signers
- multisig threshold
- timelock duration
- proxy standard
- upgradeable component
- emergency role
- oracle/indexer/RPC provider
- bridge mechanism
- UTTT canonical supply model
- exact contract interface
- mainnet parameter

Those require later evidence and explicit acceptance.

## Next architecture gates

UTTC.0.R6: RPC/oracle/indexer trust model.
UTTC.0.R7: privacy and data classification.
UTTC.0.FINAL: architecture freeze.
