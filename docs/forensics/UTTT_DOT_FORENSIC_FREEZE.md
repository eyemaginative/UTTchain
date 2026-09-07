# UTTT Polkadot Asset Hub / Hydration Forensic Freeze

## Status

**FINAL / ACCEPTED**

This document freezes the accepted Polkadot Asset Hub and
Hydration forensic record for Unified Trading Terminal Token
(UTTT) within UTTchain.

It combines accepted identity, historical issuance, XCM lineage,
reserve accounting, trapped-asset, holder, liquidity, and
administrative-control evidence from the UTTC.1.DOT tranche.

This artifact does **not** select the globally canonical UTTT
economic representation. Global canonicality remains deferred
until Robinhood Chain, Solana, Polkadot, Hydration, and
Counterparty state are reconciled together.

This artifact also does not convert a designated custodial reserve
into an immutable or trustless lock by description.

---

## 1. Domain topology

The accepted remote UTTT topology is:

```text
Polkadot Asset Hub
asset 50000456
        |
        | XCM external-asset location
        v
Hydration
asset 1001331
```

Hydration asset `1001331` is an XCM representation surface of
Asset Hub asset `50000456` and is **not additive economic supply**.

---

## 2. Polkadot Asset Hub identity

Asset ID:

`50000456`

Name:

Unified Trading Terminal Token

Symbol:

UTTT

Decimals:

6

Accepted current state:

- status: Live
- supply: 40,000,000 UTTT
- raw supply: 40000000000000
- asset accounts: 3
- minimum balance: 1 raw unit
- sufficient: false

Accepted administrative roles:

`13xijG3AEoh1MFAjBndnQE9CDmF8hBkvTqgLbBsxb181ZYa2`

The same account currently occupies:

- owner
- issuer
- admin
- freezer

The evidence establishes role concentration. It does not by itself
establish a treasury label, beneficial ownership, or private-key
custody identity.

---

## 3. Asset Hub creation

First storage presence:

- height: 13254492
- block hash:
  `0xeec8dce5512be453bd955c91760070dcfb0e76dcf362ac70e3d36bd8537e3c4c`
- UTC: 2026-03-10T23:12:36Z
- immediately preceding height: asset absent
- first-present supply: 0

Creation-block evidence included a successful `utility.batchAll`
containing the UTTT asset creation/metadata operation.

Matching accepted events:

- `assets.Created` for asset 50000456
- `assets.MetadataSet`
- name: Unified Trading Terminal Token
- symbol: UTTT
- decimals: 6

---

## 4. Asset Hub issuance chronology

Accepted supply transitions are exactly:

### Transition 1

- height: 13277278
- UTC: 2026-03-11T13:22:48Z
- pre-supply: 0
- post-supply: 30,000,000 UTTT
- delta: +30,000,000 UTTT
- raw delta: 30000000000000
- matching event: `assets.Issued`

### Transition 2

- height: 16217025
- UTC: 2026-05-25T16:31:48Z
- pre-supply: 30,000,000 UTTT
- post-supply: 40,000,000 UTTT
- delta: +10,000,000 UTTT
- raw delta: 10000000000000
- matching event: `assets.Issued`

No accepted Asset Hub burn transition was discovered in the
reconstructed supply-plateau chronology.

The two issuance transitions net exactly to the accepted
40,000,000 UTTT Asset Hub supply.

---

## 5. Hydration chain and asset identity

Chain:

Hydration

EVM chain ID:

`222222`

Genesis hash:

`0xafdc188f45c71dacbaa0b62e16a91f726c7b8699a9748cdf715459de6b7f366d`

Hydration asset ID:

`1001331`

Accepted registry class:

`External`

Accepted current native registry state:

- name: absent
- symbol: absent
- decimals: absent
- existential deposit: 1
- is sufficient: false

The absence of current Hydration-local metadata does not erase
the chain-proven external-asset identity binding.

Accepted current runtime observed during R2:

- spec version: 440
- transaction version: 1

---

## 6. Hydration XCM location binding

Hydration `AssetLocations(1001331)` decodes as:

```text
parents = 1
X3 = [
  Parachain(1000),
  PalletInstance(50),
  GeneralIndex(50000456)
]
```

This directly binds Hydration asset 1001331 to the accepted
Asset Hub UTTT asset 50000456.

The registry and location first appeared together at:

- Hydration height: 11739444
- block hash:
  `0x0c0f5fae3a06d7edf98ff9847f015c9b0de8ff182c93088b928cbf02cd2dd034`
- UTC: 2026-03-15T20:55:12Z
- immediately preceding height: absent
- Hydration UTTT issuance at first presence: 0

---

## 7. Hydration issuance chronology

Accepted distinct issuance transitions:

### Transition 1

- height: 12328455
- UTC: 2026-05-07T05:43:54Z
- pre: 0
- post: 1 UTTT
- delta: +1 UTTT
- raw delta: 1000000

### Transition 2

- height: 12333920
- UTC: 2026-05-07T18:25:48Z
- pre: 1 UTTT
- post: 10,000,001 UTTT
- delta: +10,000,000 UTTT
- raw delta: 10000000000000

### Transition 3

- height: 12507645
- UTC: 2026-05-25T17:50:54Z
- pre: 10,000,001 UTTT
- post: 20,000,000.999999 UTTT
- delta: +9,999,999.999999 UTTT
- raw delta: 9999999999999

### Transition 4

- height: 12508293
- UTC: 2026-05-25T19:17:42Z
- pre: 20,000,000.999999 UTTT
- post: 39,999,998.999998 UTTT
- delta: +19,999,997.999999 UTTT
- raw delta: 19999997999999

The four accepted transitions net exactly to:

`39,999,998.999998 UTTT`

Raw:

`39999998999998`

---

## 8. Hydration sibling-sovereign reserve

Hydration parachain ID:

`2034`

Derived sibling-sovereign account on Asset Hub:

`13cKp89Uh2yWgTG28JA1QEvPUMjEPKejqkjHKf9zqLiFKjH6`

Accepted current UTTT balance:

`39,999,999.999998 UTTT`

Raw:

`39999999999998`

Accepted sovereign reserve transitions:

1. 2026-05-05T22:09:00Z: +1 UTTT
2. 2026-05-07T05:43:24Z: +1 UTTT
3. 2026-05-07T18:25:00Z: +10,000,000 UTTT
4. 2026-05-25T17:50:24Z: +9,999,999.999999 UTTT
5. 2026-05-25T19:16:48Z: +19,999,997.999999 UTTT

Those reserve transitions net exactly to the accepted current
sovereign balance.

---

## 9. First trapped 1 UTTT XCM attempt

The first accepted source-side attempt occurred on:

- Asset Hub UTC: 2026-05-05T22:09:00Z
- source transaction/extrinsic hash:
  `0x6a7a43a1e75d6d08b077586620ce20b7b62a3f28d0b57045dbf6f958904b2cf4`
- call: V5 `polkadotXcm.limitedReserveTransferAssets`
- destination: Hydration
- asset set: UTTT only
- feeAssetItem: 0
- weight limit: Unlimited

Asset Hub transferred exactly 1 UTTT into the Hydration
sibling-sovereign reserve.

Hydration created no corresponding UTTT representation.

Canonical destination evidence was recovered directly from
historical Hydration runtime state.

At Hydration block 12315789:

- block hash:
  `0xc979f91e476082b9449191f44e9ac99540023acbcd0778e5a9e0f0e0948df230`
- `PolkadotXcm.AssetsTrapped` was emitted
- origin: Asset Hub / Parachain(1000)
- asset path:
  Parachain(1000) / PalletInstance(50) / GeneralIndex(50000456)
- trapped fungible amount raw: 1000000
- trapped amount: 1.000000 UTTT
- `MessageQueue.Processed` from Sibling(1000) reported
  `success=false`

Accepted raw `System.Events` evidence:

- bytes: 158
- SHA256:
  `e908f6687dc313ab4b0c23b850feb96bbf892a4b1461b93e99704ddf43dcc368`

The 1 UTTT was therefore trapped/unrepresented, not destroyed.
It remains part of the Asset Hub sovereign reserve.

---

## 10. Successful USDt-fee repair

The second accepted source-side attempt occurred on:

- Asset Hub UTC: 2026-05-07T05:43:24Z
- source transaction/extrinsic hash:
  `0xd4723ccd05b3a649ec86e8807a2ed00dd6662bbec7877715bd55697c13e9bbc9`
- call: V5 `limitedReserveTransferAssets`
- fee asset first: Asset Hub USDt 1984
- fee amount: 0.02 USDt
- UTTT second: asset 50000456 / 1 UTTT
- feeAssetItem: 0
- weight limit: Unlimited

The first successful Hydration UTTT issuance followed at:

- Hydration height: 12328455
- block hash:
  `0x008b92c92db870f15963eab3961c8c02039048743555fcd29507c277306946f0`
- UTC: 2026-05-07T05:43:54Z
- issuance: 0 -> 1 UTTT

The accepted destination window contained a successful
`MessageQueue.Processed` event from Sibling(1000), and no
UTTT-bound `AssetsTrapped` event.

The same block also contained a separate failed Sibling(1000)
message. The evidence does not claim that every XCM message in
the block succeeded.

Accepted raw `System.Events` evidence for the successful block:

- bytes: 817
- SHA256:
  `f539bd69aaa5e9c687e08c61e3373ea1c7928c0bb63d4015c3d25ff03b19080f`

---

## 11. Historical runtime-event evidence

The XCM destination proof does not depend on Subscan.

Historical Hydration runtime metadata used for the accepted
event decode:

- metadata version: 14
- runtime spec version: 411
- metadata bytes: 512829
- metadata SHA256:
  `5d189567e394b709b22d16bc772201ed3173cc1c6b091f3222bb75e692123878`

Accepted evidence path:

```text
canonical Hydration archive RPC
+ historical block hash
+ historical runtime metadata
+ raw System.Events
+ metadata-aware SCALE decoding
```

Subscan/PubFi is not required for this forensic conclusion.

---

## 12. Current Asset Hub distribution

The complete accepted current Asset Hub UTTT distribution
contains three accounts:

### Hydration sibling-sovereign

`13cKp89Uh2yWgTG28JA1QEvPUMjEPKejqkjHKf9zqLiFKjH6`

- balance: 39,999,999.999998 UTTT
- raw: 39999999999998

### Accepted source-linked account

`13objXyssq1sJbqMJCmCjHP6aEhJuaRVbYGESnTgqdsQMfjU`

- balance: 0.000001 UTTT
- raw: 1

### Administrative-role account

`13xijG3AEoh1MFAjBndnQE9CDmF8hBkvTqgLbBsxb181ZYa2`

- balance: 0.000001 UTTT
- raw: 1

Conservation:

```text
39,999,999.999998
+        0.000001
+        0.000001
=40,000,000.000000 UTTT
```

---

## 13. Hydration / sovereign decomposition

Accepted current relation:

```text
39,999,999.999998  Asset Hub Hydration-sovereign reserve
-39,999,998.999998  Hydration represented issuance
=        1.000000  trapped / unrepresented reserve
```

The full remote 40M line decomposes as:

```text
39,999,998.999998  Hydration represented issuance
+        1.000000  trapped / unrepresented reserve
+        0.000002  Asset Hub outside-sovereign residual
=40,000,000.000000  Asset Hub supply
```

This decomposition closes the previously observed
1.000002 UTTT Asset Hub-versus-Hydration difference.

---

## 14. Solana / Polkadot current economic non-overlap

Accepted Solana current supply:

`999,997,438.658454 UTTT`

Accepted designated Solana bridge reserve:

`40,000,000 UTTT`

Accepted Solana supply outside that reserve:

`959,997,438.658454 UTTT`

Current reserve/accounting equality:

```text
40,000,000 Solana designated reserve
=
40,000,000 Asset Hub remote economic line
```

Current anti-double-counting equation:

```text
959,997,438.658454  Solana outside designated reserve
+40,000,000.000000  Asset Hub remote economic line
=999,997,438.658454  current SOL + DOT economic amount
```

Hydration issuance is contained inside the Asset Hub 40M line
and must not be added again.

---

## 15. 10M lineage

Accepted Solana designated-reserve chronology:

- +10M: 2026-05-25T16:23:09Z
- +30M: 2026-07-01T05:27:50Z

Accepted Asset Hub issuance chronology:

- +30M: 2026-03-11T13:22:48Z
- +10M: 2026-05-25T16:31:48Z

For the 10M tranche:

- Solana reserve +10M occurred first
- Asset Hub +10M issuance followed 519 seconds later
- elapsed time: 8 minutes 39 seconds

The accepted UTT model classifies this tranche as:

`vault_deposit_mint_xcm`

This is accepted as source-first bridge lineage.

---

## 16. Initial 30M lineage

The initial 30M Asset Hub issuance occurred on 2026-03-11.

The corresponding +30M Solana designated-reserve deposit did
not occur until 2026-07-01.

Accordingly:

- source-before-mint causality is **not** claimed
- continuous historical backing before 2026-07-01 is
  **not proven**
- no unobserved lock, burn, escrow, or reserve is invented

The later +30M Solana reserve deposit exactly satisfies the
current deferred 30M backing amount.

Accepted classification:

**post-issuance backing / accounting reconciliation**

---

## 17. Current Hydration positive-holder census

The accepted complete current positive-holder census contains
exactly three UTTT holders and conserves the full Hydration
issuance.

### Holder 1

`13xijG3AEoh1MFAjBndnQE9CDmF8hBkvTqgLbBsxb181ZYa2`

- balance: 38,999,999.999999 UTTT
- raw: 38999999999999
- share: 97.500002%
- free: full balance
- reserved: 0
- frozen: 0
- accepted class:
  `ASSET_HUB_ADMIN_AUTHORITY_LINKED_NONMARKET_CUSTODY`

The class reflects the same-account link to the current Asset
Hub owner/issuer/admin/freezer roles and the absence of that
account from the measured UTTT market surfaces.

It does not assert treasury status, beneficial ownership, or
private-key identity.

### Holder 2

`15UchSssnctYqtub7HrSB3ifWoAqMza3uRQ7x8cB6aJsivy`

- balance: 922,349.937273 UTTT
- raw: 922349937273
- share: 2.305875%
- free: full balance
- reserved: 0
- frozen: 0
- accepted class: `XYK_POOL`

### Holder 3

`13objXyssq1sJbqMJCmCjHP6aEhJuaRVbYGESnTgqdsQMfjU`

- balance: 77,649.062726 UTTT
- raw: 77649062726
- share: 0.194123%
- free: full balance
- reserved: 0
- frozen: 0
- accepted class:
  `ACCEPTED_XCM_SOURCE_LINKED_NONMARKET_HOLDER`

The class reflects the same-account relation to the accepted
Asset Hub XCM source and its absence from the measured current
UTTT market-account set.

It does not assert ordinary-user status or private-key identity.

Holder conservation:

```text
38,999,999.999999
+   922,349.937273
+    77,649.062726
=39,999,998.999998 UTTT
```

---

## 18. Current Hydration liquidity role

Exactly one accepted current UTTT XYK pool was observed.

Pool account:

`15UchSssnctYqtub7HrSB3ifWoAqMza3uRQ7x8cB6aJsivy`

Pool pair:

`[1001331, 0]`

Asset 1001331:

UTTT external representation

Partner asset 0 current registry evidence:

- name: Hydration
- symbol: HDX
- decimals: 12
- asset class: Token
- is sufficient: true

UTTT held by the XYK pool:

`922,349.937273 UTTT`

Additional accepted storage observations:

- pool System.Account free raw: 849286724542022
- pool Tokens.Accounts(asset 0) free: 0
- XYK TotalLiquidity storage value: 782450000000000

Those additional values are recorded as storage observations;
they are not promoted here into unsupported pool-economic or LP
ownership claims.

Across the measured current Hydration storage surfaces:

- XYK: UTTT present
- Omnipool: no UTTT state observed
- StableSwap: no UTTT state observed
- LBP: no UTTT state observed
- OTC: no UTTT state observed

The resulting market-role classification is therefore scoped as
**XYK-only across the measured surfaces**.

---

## 19. Authority boundary

Asset Hub has explicit current UTTT administrative roles and
those roles are concentrated in one account.

Hydration asset 1001331 is registered as an External asset whose
location points to Asset Hub asset 50000456.

The accepted Hydration registry entry does not expose equivalent
per-asset owner, issuer, admin, or freezer fields.

Therefore the evidence does not treat Hydration as an independent
UTTT issuance-authority domain.

---

## 20. Provider / decoder boundary

Accepted evidence used multiple replaceable read-only surfaces,
including:

- Polkadot Asset Hub public Sidecar
- Hydration Dwellir RPC / archive RPC
- direct historical System.Events storage
- historical runtime metadata
- local metadata-aware `polkadot-api` decoding

The accepted local decoder version was:

`polkadot-api 2.1.1`

Subscan transport was unavailable during the forensic tranche and
was removed from the destination-side proof dependency.

No negative chain conclusion was inferred from Subscan failure.

---

## 21. Economic interpretation

The accepted current economic interpretation is:

1. Asset Hub 50000456 is the 40M remote supply line.
2. Hydration 1001331 is a representation of that Asset Hub line.
3. Hydration issuance must not be counted additively.
4. One exact UTTT remains trapped/unrepresented in the Asset Hub
   Hydration sovereign reserve.
5. Two additional Asset Hub raw units remain outside the
   sovereign account.
6. The designated 40M Solana reserve currently equals the full
   40M Asset Hub remote line.
7. This supports current reserve-backed accounting non-overlap.
8. The Solana reserve is system-owned and transferable, not an
   immutable trustless escrow.
9. Continuous historical 30M backing before July 1, 2026 is not
   proven and is not asserted.

---

## 22. What this freeze does not decide

This artifact does not:

- select Solana, Asset Hub, Hydration, or Robinhood Chain as the
  globally canonical economic UTTT representation
- authorize any UTTT mint
- authorize any UTTT burn
- authorize migration
- authorize bridge or XCM execution
- authorize market activity
- transfer administrative authority
- claim immutable reserve custody
- claim continuous historical backing where not proven
- assign a treasury label without evidence
- identify private-key controllers

Those questions remain outside this forensic freeze.

---

## 23. Accepted disposition

**UTTC.1.DOT — FINAL / ACCEPTED**

The Polkadot Asset Hub / Hydration UTTT forensic domain is frozen
as an accepted UTTchain evidence record.

Next forensic domain:

**UTTC.1.XCP — Counterparty UTTT reconstruction**

Global UTTT economic canonicality remains explicitly unselected.
