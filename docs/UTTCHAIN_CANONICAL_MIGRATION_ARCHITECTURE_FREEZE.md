# UTTchain Canonical UTTT Migration Architecture Freeze

## Status

**UTTC.2.FINAL — FINAL / ACCEPTED**

This document binds the accepted `UTTC.2.R0`, `UTTC.2.R1`, `UTTC.2.R2`
(accepted through `UTTC.2.R2.R1`), and `UTTC.2.R3` decisions into the
canonical UTTT migration architecture. The original R2 source-marker failure
was a read-only harness false negative and is superseded.

This is an architecture freeze, not authorization to deploy contracts, mutate
legacy assets, select cutover blocks, collect signatures, propose/activate a
root, register a holder, or execute a claim.

## 1. Canonical economics

Historical root: the accepted Solana 1,000,000,000 UTTT genesis ledger.

Canonical precision: 6 decimals.

```text
historical maximum       1000000000000000 base units
accepted historical burn       2561341546 base units
canonical fixed amount      999997438658454 base units

999997438658454 + 2561341546 = 1000000000000000
```

`2,561.341546 UTTT` is permanently retired. Canonical migration may never
recreate it.

The master economic entitlement dataset must sum exactly to
`999997438658454` base units. Legacy representations, reserves, aliases,
registration roots, reviewers, or deployment mechanisms may not increase that
amount.

## 2. Canonical token and genesis custody

Canonical UTTT is a new Robinhood Chain ERC-20 on chain ID `4663`:

```text
name     Unified Trading Terminal Token
symbol   UTTT
decimals 6
supply   999997438658454 base units
```

Minimal V1 is immutable and non-proxy with standard ERC-20 accounting only:
no post-deployment mint, burn function, owner, AccessControl, tax, blacklist,
pause, airdrop policy, reflection, rebase, oracle/indexer/bridge dependency,
hosted-service dependency, generic delegatecall, or arbitrary execution.

The legacy Robinhood Chain 420M contract remains non-canonical. Its 18-decimal
nominal format and administrative authority do not control the canonical token.

The entire canonical genesis supply is minted directly to a separate
`MigrationVault`, never to an ordinary EOA. Claims transfer pre-minted UTTT;
claims never mint.

The vault is immutable, non-proxy, ownerless, and has no canonical-UTTT sweep,
rescue, treasury withdrawal, arbitrary call, or delegatecall path. Claim
capacity is entitlement/nullifier bound rather than raw-balance bound.
`claimedUnits` is monotonic and cannot exceed `999997438658454`.

Unclaimed entitlement has no default expiry and is not silently forfeited or
reallocated.

## 3. Economic entitlement root

Migration domain:

```text
UTTCHAIN_UTTT_MIGRATION_V1
```

Entitlement-ID domain:

```text
UTTCHAIN_UTTT_ENTITLEMENT_ID_V1
```

Conceptual entitlement ID:

```text
keccak256(
  abi.encode(
    ENTITLEMENT_ID_DOMAIN,
    migrationId,
    uint64(entitlementIndex),
    bytes32(rootedRecordHash)
  )
)
```

Economic-leaf domain:

```text
UTTCHAIN_UTTT_ENTITLEMENT_LEAF_V1
```

Economic leaf:

```text
keccak256(
  bytes.concat(
    keccak256(
      abi.encode(
        ENTITLEMENT_LEAF_DOMAIN,
        migrationId,
        entitlementId,
        uint64(amountUnits)
      )
    )
  )
)
```

Structured identities use `abi.encode`, not `abi.encodePacked`.

The master dataset is deterministic, canonically sorted, content-addressed,
integer-only in six-decimal base units, and contains one non-overlapping rooted
economic row per entitlement. Legacy aliases and reserve/custody identities
cannot add economic value.

The economic root becomes immutable when accepted and deployment-bound.

## 4. Destination registrations and nullifier

Destination registration is separate from economic entitlement.

Registration-leaf domain:

```text
UTTCHAIN_UTTT_REGISTRATION_LEAF_V1
```

Registration leaf:

```text
keccak256(
  bytes.concat(
    keccak256(
      abi.encode(
        REGISTRATION_LEAF_DOMAIN,
        migrationId,
        entitlementId,
        uint256(4663),
        destination,
        sourceControlProofHash,
        registrationEpoch
      )
    )
  )
)
```

The registration leaf contains no amount. Amount comes only from the immutable
economic proof.

Within an epoch, an `entitlementId` appears at most once. Later registration
roots cover previously unregistered entitlement IDs only; destination rebinding
is invalid in minimal V1.

Unregistered entitlement remains preserved and may be registered later through
a supplemental accepted root.

Nullifier domain:

```text
UTTCHAIN_UTTT_NULLIFIER_V1
```

Global nullifier:

```text
keccak256(
  abi.encode(
    NULLIFIER_DOMAIN,
    migrationId,
    entitlementId
  )
)
```

The nullifier excludes destination, legacy domain, legacy token, and
registration epoch. One rooted economic entitlement can therefore pay once.

A claim requires both Merkle proofs, an accepted registration root, an unused
global nullifier, the exact registered destination, `msg.sender` equal to that
destination, and the exact full entitlement amount. Partial claims and
caller-selected amounts are excluded from minimal V1.

Canonical nullifier state lives on Robinhood Chain, not in an indexer or server
database.

## 5. Multi-domain cutover and source control

UTTC.1 forensic checkpoints are provenance anchors, not retroactive holder
snapshots.

Migration uses a future explicitly announced cutover manifest binding:

- finalized Solana slot/block identity
- finalized Asset Hub block/hash
- finalized Hydration block/hash
- Bitcoin height/hash for Counterparty
- Robinhood Chain block/hash
- migration-domain and global-freeze identities
- per-domain dataset/state hashes
- cross-domain reconciliation hash

Different chains need not share the same wall-clock second, but every
inter-anchor bridge/XCM movement must reconcile. Unclassified in-flight remote
state is HOLD and blocks the master root.

Each domain is replayed from its accepted forensic anchor through cutover.
Before cutover, transfers may move beneficial ownership without changing total
economics. After cutover, legacy transfers do not move canonical entitlement.

Post-freeze unbacked legacy issuance creates zero canonical entitlement.
Post-freeze legacy retirement does not silently reduce the frozen economic root
unless the economic model is explicitly reopened.

Source-control challenges bind migration ID, entitlement ID, source domain,
source identity, snapshot reference, destination chain `4663`, destination,
and registration epoch. Evidence bundles are content-addressed and bind the
exact challenge, signature/onchain authorization, source identity, snapshot,
verifier version, and result. Secrets are never stored.

Ambiguous source control is HOLD, not forfeiture.

## 6. Domain rules

### Solana

Use a finalized cutover snapshot. Direct rooted holders are included; the
designated bridge reserve is excluded as a second beneficial entitlement for
remote-backed units.

Source control uses the accepted Solana off-chain-message model with Ed25519;
`solana:signOffchainMessage` is preferred. Generic `signMessage` is accepted
only when exact accepted serialized bytes are signed and verified. PDA/program
or custodial identities require explicit beneficial/program authorization or
remain HOLD.

Accepted supply-expansion terminal state:

```text
mint authority   NONE
freeze authority NONE
```

Physical zeroing is not required for claim security. Post-cutover Solana UTTT
is legacy/non-canonical and creates no new claim rights.

### Asset Hub / Hydration

Use paired finalized snapshots with exact remote reconciliation.

The Asset Hub Hydration sibling-sovereign account is reserve/custody, not a
second beneficial entitlement. Hydration beneficial holders replace the
corresponding sovereign amount. Asset Hub non-sovereign holders are direct
rows. No reserve unit can appear twice.

Accepted remote decomposition:

```text
39999998.999998  Hydration represented
       1.000000  trapped/unrepresented
       0.000002  Asset Hub residual
=40000000.000000 UTTT
```

The trapped amount remains HOLD until beneficial source is proven. Residual
units belong only to actual snapshot holders.

Ordinary Polkadot control verifies the actual sr25519, Ed25519, or ECDSA type.
Unsuitable multisig/proxy identities may use an accepted finalized onchain
authorization of the exact challenge hash.

Legacy Asset Hub owner/issuer/admin/freezer roles do not become canonical
authority. Before claim activation, project-controlled supply/admin authority
must receive an accepted terminal disposition. Preferred direction after
snapshot/evidence freeze is an accepted destroying/destroyed sequence. Exact
live mutation sequencing requires a separate feasibility gate.

### Counterparty

Counterparty UTTT is a non-additive legacy alias.

Quantity issuance must be irreversibly locked before the final Counterparty
cutover snapshot. Description lock is not sufficient. Accepted terminal parsed
state must report:

```text
locked=true
```

Snapshot binds exact Bitcoin height/hash and Counterparty parsed state with a
minimum 12-confirmation acceptance window.

Source control uses BIP-322 full-format proof over the exact migration
challenge. One indivisible legacy UTTT maps to 1,000,000 canonical base units
only when it is proven as an alias of an existing rooted entitlement.

Controlled legacy units should be destroyed after snapshot/evidence freeze
where feasible. Destruction is physical retirement, not a reduction of the
frozen canonical root.

### Legacy Robinhood Chain

The 420M legacy contract is alias evidence only and cannot set or enlarge claim
amount.

Snapshot binds chain ID `4663`, exact legacy token, block/hash, holder-state
hash, and relevant administrative state.

EOA control uses EIP-712. Contract-wallet control uses ERC-1271 over the exact
typed digest. Unsupported authorization is HOLD.

Legacy 18-decimal nominal units are never mechanically converted into new
six-decimal claim value.

Preferred physical retirement after snapshot/evidence freeze is transfer of
the controlled legacy balance to the deterministic immutable `RetirementSink`,
followed by reconciliation and only then legacy-owner renunciation. A surviving
unretired legacy representation remains explicitly duplicate-live/non-canonical
and creates no new claim rights.

No forced confiscation of uncontrolled holder tokens is authorized.

## 7. Claim-activation barriers

Claims do not activate merely because canonical contracts exist.

Required barriers include:

1. final content-addressed cutover manifest
2. exact-sum master entitlement dataset/root
3. Solana mint authority remains `NONE`
4. Counterparty quantity issuance is irreversibly locked
5. Asset Hub project-controlled supply/admin path has accepted terminal treatment
6. no unclassified Solana/Asset Hub/Hydration in-flight movement
7. deployed/reconciled registration-root authority
8. accepted source-to-runtime and deterministic-deployment reconciliation

Claim activation and complete physical retirement of every legacy ledger are
distinct states. Any surviving representation after cutover remains
non-canonical and receives no new entitlement.

## 8. Registration-root authority and lifecycle

The immutable `RegistrationRootRegistry` begins with exactly five distinct
nonzero reviewer identities under independent custody.

Threshold is permanently:

```text
3 of 5
```

There is no single admin.

Reviewers may authorize registration-root governance only. They cannot mint,
burn, withdraw vault UTTT, alter the economic root, reset nullifiers, override
claims, withdraw treasury assets, or make arbitrary legacy calls.

Any relayer may submit a root proposal only with three unique valid EIP-712
reviewer signatures. The domain binds registry address, chain ID `4663`,
version, and migration ID.

Proposal commitments bind nonce, registration epoch, root, dataset SHA256,
source-evidence root, manifest hash, record count, and previous accepted
manifest hash.

Only one proposal may be pending. Proposal nonce increments on every proposal,
including canceled proposals. Registration epoch increments only on acceptance.

Every root waits:

```text
1209600 seconds
14 days
```

There is no emergency activation, delay shortening, reviewer bypass, or
initial-root exception.

Public challenge is evidence review rather than a permissionless onchain veto.
A defective pending root can be canceled only by a new 3-of-5 authorization.
After the delay, activation is permissionless and accepts the exact signed
commitments or nothing.

Accepted roots are append-only, immutable, never removed, replaced, or rolled
back. The global nullifier prevents payment replay across roots.

Cross-epoch disjointness is reproduced from content-addressed datasets during
public review. The reviewer quorum is the explicit bounded trust surface for
cross-chain evidence that the EVM registry does not natively verify.

## 9. Reviewer continuity

Reviewer-set rotation requires three current-reviewer approvals over exactly
five distinct nonzero replacement addresses.

Rotation waits:

```text
2592000 seconds
30 days
```

There is no emergency replacement, fallback single key, or threshold
reduction. A root proposal and reviewer rotation cannot be pending
simultaneously.

## 10. Deterministic deployment

Canonical components:

```text
RegistrationRootRegistry
MigrationVault
RetirementSink
CanonicalUTTT
```

A one-shot immutable ownerless `UTTchainGenesisFactory` deploys them. The
factory has no treasury, arbitrary call, generic delegatecall, or post-genesis
component-deployment authority and is inert after successful genesis.

The factory bootstrap address must be source-to-runtime reconciled before
component addresses are frozen.

Each component uses CREATE2 with a domain-separated salt.

Deployment domain:

```text
UTTCHAIN_UTTT_DEPLOYMENT_V1
```

Conceptual salt:

```text
keccak256(
  abi.encode(
    DEPLOYMENT_DOMAIN,
    uint256(4663),
    migrationId,
    componentTag,
    deploymentManifestHash
  )
)
```

CREATE2 address derives from factory address, exact salt, and
`keccak256(initCode)`. A deployment manifest binds source commit, compiler,
optimizer, dependencies, constructor inputs, init-code hashes, salts, and
expected addresses.

## 11. Vault/token circularity and atomic genesis

`MigrationVault` init code does not contain the future token address. Its
constructor binds the economic root, registration registry, migration ID,
canonical genesis amount, and factory as one-time token binder.

Deployment order:

```text
RegistrationRootRegistry
MigrationVault
RetirementSink
CanonicalUTTT
one-time vault token binding
finalize
```

The vault address is precomputed first. `CanonicalUTTT` receives that vault
address and mints exactly `999997438658454` base units directly to it.

The factory binds the deployed canonical token into the vault exactly once.
Binding verifies name, symbol, 6 decimals, exact total supply, and the complete
genesis balance held by the vault.

All component deployments and token binding occur atomically in one factory
genesis transaction; any failure reverts all. `deployAll` is one-shot and
rejects the wrong chain ID.

## 12. Retirement sink and deployment reconciliation

`RetirementSink` is deterministic with immutable runtime and zero
administrative storage. It has no owner, withdrawal, approval, transfer,
delegatecall, selfdestruct, or arbitrary execution path. It is only a later
legacy-RH physical-retirement destination and has no canonical claim role.

A legacy transfer to it remains separately gated.

Production deployment acceptance requires:

- source-to-init-code reproduction
- init-code-to-CREATE2-address reproduction
- address-to-runtime reproduction
- expected bytecode and immutables
- token identity and exact total supply
- exact vault genesis balance and token binding
- registration-registry governance state
- reviewer threshold and delay constants
- migration/economic-root bindings

Any mismatch is HOLD and blocks root activation.

## 13. Security boundary

The immutable economic root controls canonical economic amount. Registration
reviewers cannot change supply or master entitlement.

A compromised 3-of-5 quorum could misbind an **unclaimed** entitlement to an
incorrect destination. Mitigation is independent custody, exact EIP-712
commitments, public content-addressed datasets/evidence, immutable 14-day
review, observable signatures, append-only roots, the global nullifier, and
30-day delayed reviewer rotation.

An already-claimed entitlement cannot be economically reallocated.

Indexers, APIs, proof-discovery services, and static hosting are non-canonical.
The claim path remains user wallet + replaceable Robinhood Chain RPC +
canonical Robinhood Chain contracts; no mandatory UTT backend, localhost
daemon, or project-hosted API has claim authority.

## 14. Deferred implementation inputs and authorization boundary

Still intentionally unfrozen:

- exact five initial reviewer addresses
- exact Solidity source and source commit
- compiler/optimizer/dependency versions
- factory bootstrap address
- deployment manifest hash
- component salts/init-code hashes/CREATE2 addresses
- future cutover heights/hashes
- actual master economic root
- actual registration roots
- source-control/reviewer signatures
- proposal/review/activation transactions

This freeze authorizes none of those actions.

It also does not authorize Counterparty lock/destruction, Asset Hub/Hydration
mutation, Solana mutation, legacy-RH retirement/renunciation, canonical
deployment, holder registration/claim, bridge execution, or market action.

## 15. Final architecture

```text
Solana 1B historical root
        |
        |- 2,561.341546 permanently retired
        v
999,997,438.658454 canonical economic amount
        |
        v
future explicit multi-domain cutover
        |
        v
immutable economic entitlement root
        |
        +-- source-control evidence
        |
        v
append-only destination-registration roots
3-of-5 reviewers / 14-day review
        |
        v
MigrationVault
        |
global entitlementId nullifier
        |
        v
registered Robinhood Chain destination
```

Deterministic genesis:

```text
UTTchainGenesisFactory
  +-- CREATE2 RegistrationRootRegistry
  +-- CREATE2 MigrationVault
  +-- CREATE2 RetirementSink
  +-- CREATE2 CanonicalUTTT -> full fixed supply to MigrationVault
  +-- bind token once
  +-- inert forever
```

Accepted design tranches:

```text
UTTC.2.R0  ACCEPTED
UTTC.2.R1  ACCEPTED
UTTC.2.R2  ACCEPTED via UTTC.2.R2.R1
UTTC.2.R3  ACCEPTED
```

**UTTC.2.FINAL — FINAL / ACCEPTED**

The canonical UTTT migration architecture is frozen. Implementation proceeds
only through separately gated UTTC.3 work.
