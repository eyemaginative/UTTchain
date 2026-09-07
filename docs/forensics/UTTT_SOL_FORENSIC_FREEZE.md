# UTTT Solana Forensic Freeze

## Status

**FINAL / ACCEPTED**

This document freezes the accepted Solana forensic record for Unified
Trading Terminal Token (UTTT) within UTTchain.

It records immutable historical facts and explicitly identified
observation snapshots established by the accepted `UTTC.1.SOL`
forensic tranche.

This artifact does not select the globally canonical UTTT economic
representation. Global economic canonicality remains deferred until
Robinhood Chain, Solana, Polkadot/Asset Hub/Hydration, and Counterparty
state are reconciled together.

---

## 1. Solana token identity

Chain:

- Solana Mainnet
- genesis hash: `5eykt4UsFv8P8NJdTREpY1vzqKqZKvdpKuc147dw2N9d`

Mint:

`8Fgj9xYY8mtYPUREUm9aAuYaprMdzLcTARiUV4oppump`

Token program:

`TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb`

Program class:

Token-2022

Name:

Unified Trading Terminal Token

Symbol:

UTTT

Decimals:

6

Accepted Token-2022 extensions:

- metadata pointer
- token metadata

Accepted current authority state:

- base mint authority: NONE
- base freeze authority: NONE
- metadata-pointer authority: NONE
- token-metadata update authority: NONE

---

## 2. Historical creation and issuance

Creation slot:

`401452554`

Creation UTC:

`2026-02-20T04:12:38Z`

Creation transaction:

`3RzRmKKDrFSYXAqdGsm8kvKVuwNaWFHgmAVrtXn2nNpMG1RNWVhTt58gYwMUwWtUQBExVpWnDdLFy4EWySeTnDFZ`

Initial base mint authority:

`TSLvdd1pWpHVjahSpsvCXUbgwsL3JAcvokwaKt1eokM`

Initial freeze authority:

NONE

Historical gross issuance:

`1,000,000,000 UTTT`

Raw issuance:

`1000000000000000`

Accepted historical event count:

- mint events: 1
- burn events: 8
- total burns: 2,561.341546 UTTT

Accepted supply at the forensic checkpoint:

`999,997,438.658454 UTTT`

Supply reconciliation:

    1,000,000,000.000000
    -       2,561.341546
    --------------------
      999,997,438.658454 UTTT

Exactly one historical mint event was found.

---

## 3. Mint and metadata authority retirement

The creation transaction initialized the mint with authority:

`TSLvdd1pWpHVjahSpsvCXUbgwsL3JAcvokwaKt1eokM`

A mint-targeted Token-2022 `setAuthority` instruction in that same
transaction established:

    authority_type=mintTokens
    prior=TSLvdd1pWpHVjahSpsvCXUbgwsL3JAcvokwaKt1eokM
    new=NONE

Accepted authority lifecycle:

- mint-authority transitions: 1
- freeze-authority transitions: 0
- derived mint authority: NONE
- derived freeze authority: NONE
- current mint authority: NONE
- current freeze authority: NONE

The accepted creation transaction also initialized token metadata and
retired its update authority to NONE.

Accepted metadata authority state:

- metadata-pointer authority: NONE
- metadata address: UTTT mint
- token-metadata update authority: NONE

---

## 4. Historical transaction corpus

Accepted standard mint-address signature corpus:

- total signatures: 4,423
- successful: 4,118
- failed: 305

Successful ordered corpus SHA256:

`7684bee9a3c4b327852a9fe836a4436f9636fa7e8387eecac8010a95cefd2712`

Dedicated archival reconstruction:

- enhanced pages: 42
- successful transactions: 4,118
- exact ordered equality to the standard successful corpus
- unparsed Token-2022 instructions relevant to accepted reconstruction: 0

Failed transactions were retained as corpus controls and did not commit
token state.

---

## 5. Historical burns

Exactly eight burn events were accepted:

1. 2026-02-20T20:49:50Z — 0.000001 UTTT
2. 2026-02-21T07:55:48Z — 0.1 UTTT
3. 2026-02-22T19:33:12Z — 6.480303 UTTT
4. 2026-02-23T01:18:33Z — 0.000001 UTTT
5. 2026-02-23T01:26:17Z — 0.000001 UTTT
6. 2026-02-26T13:17:38Z — 4.705463 UTTT
7. 2026-03-10T08:22:25Z — 1,953.854384 UTTT
8. 2026-05-14T16:54:15Z — 596.201393 UTTT

Total:

`2,561.341546 UTTT`

This burn reconstruction is frozen through the accepted historical
corpus. A later new burn would be a subsequent chain event, not a
retroactive invalidation of this evidence record.

---

## 6. Designated Solana bridge reserve

Reserve token account:

`7KCLARVw8P6jhQinpHuB5tY5MLvCyiHvanpFTBVkvZen`

Reserve owner:

`4zW3sGbsrCVYYAbuDM2QgtU1Xe9qnpYPFxZSprnkTPDJ`

Accepted reserve:

`40,000,000 UTTT`

Reserve control state:

- token-account state: initialized
- delegate: NONE
- delegated amount: 0
- close authority: NONE
- owner account class: SYSTEM_OWNED
- owner program: `11111111111111111111111111111111`
- executable: false

Accepted complete available reserve signature history:

- total: 2
- successful: 2
- failed: 0

First reserve increase:

- slot: 422103102
- UTC: 2026-05-25T16:23:09Z
- transaction:
  `2LV4xnkAHArEwWgQizwSXifESrdcArPKSN61nbDeiU9qtj6fddYD9qqucCupegDSrb6iMxgckxQRPUNoPVLVdEE8`

Balance movement:

    0
    -> 10,000,000
    delta = +10,000,000 UTTT

Second reserve increase:

- slot: 430029655
- UTC: 2026-07-01T05:27:50Z
- transaction:
  `47LZPdP2YYx9sn1Sc94XoPReYgvDMhesBj6StUc1urHoirTtSkmgfckhy1cza279EPFd4z4aGjZBb7kypsNAtgNc`

Balance movement:

    10,000,000
    -> 40,000,000
    delta = +30,000,000 UTTT

Accepted source-side reserve equation:

    10M + 30M = 40M UTTT

Only those two nonzero UTTT reserve balance changes were found.

This proves the accepted Solana source-side reserve history.

It does not prove the remote Asset Hub / Hydration side. That boundary
remains `UTTC.1.DOT`.

---

## 7. Complete accepted token-account snapshot

The accepted current-state measurement reconstructed the complete
Token-2022 account ledger twice consecutively.

Snapshot A:

- finalized slot: 444895872

Snapshot B:

- finalized slot window: 444895880..444895881

Both returned the same ledger.

Accepted ledger:

- token accounts: 39
- positive token accounts: 10
- zero token accounts: 29
- positive owners: 10

Address-set SHA256:

`2d7c9bce831ff9d309d1993138b275e039522e58a60aa1c9c682acc904f091f6`

Ledger SHA256:

`2f3032e57ac7d9cb0d744f7efb7e54e20ea060ef32bfe43eefc411853d48718e`

Conservation:

    sum(all 39 token accounts)
    =
    999,997,438.658454 UTTT
    =
    accepted mint supply at snapshot

Standard largest-account cross-check:

PASS

These balances are frozen as an accepted observation snapshot, not as
a claim that live balances can never subsequently change.

---

## 8. Positive-owner snapshot

| Rank | Owner | Balance UTTT | Accepted snapshot classification |
|---:|---|---:|---|
| 1 | `5vVqzHEen5LmiEee7q5kHAigxXaUpyhXN6FNYCngFA9d` | 831,755,055.196096 | Pump BondingCurve |
| 2 | `GpMZbSM2GgvTKHJirzeGfMFoaZ8UR2X7F4v8vHTvxFbL` | 95,652,844.289627 | SYSTEM_OWNED |
| 3 | `4zW3sGbsrCVYYAbuDM2QgtU1Xe9qnpYPFxZSprnkTPDJ` | 40,000,000 | SYSTEM_OWNED designated reserve |
| 4 | `6Mu6sovSMmHQXacPpTV4cvqm3gsfhw9jgKHXf1mtzxv2` | 32,471,361.364291 | SYSTEM_OWNED |
| 5 | `2rbMgYvzAb3xDk6vXrzKkY3VwsmyDZsJTkvB3JJYsRzA` | 109,493.126587 | SYSTEM_OWNED |
| 6 | `HaJe8434xudKJuofdNdhkT1TRPDSG6VEoFbe4jfci3Fx` | 6,676.667375 | SYSTEM_OWNED |
| 7 | `D9GYt4W7VvteKCSvTgyjzuiBJyTy94Kmr6YiC9fbxGjW` | 1,137.410317 | SYSTEM_OWNED |
| 8 | `ricEmGn6WZ9kN2ASm1MAt7LoE1hBgu1VcQrjRwkAPfc` | 869.668531 | SYSTEM_OWNED |
| 9 | `6pwxLG2NRoSjHbmeV5ff3jh5pwAfbPzPENSM1yAjgc5Z` | 0.905334 | UNMATERIALIZED |
| 10 | `BM9CcyErJcu2mjrFvUsRRrD3snGeHDDVirJLvL6EjvMN` | 0.030296 | SYSTEM_OWNED |

Accepted aggregate control classes:

    SYSTEM_OWNED
    owners=8
    balance=168,242,382.557024 UTTT

    PROGRAM_OWNED
    owners=1
    balance=831,755,055.196096 UTTT

    UNMATERIALIZED
    owners=1
    balance=0.905334 UTTT

    EXECUTABLE_PROGRAM
    owners=0
    balance=0

Program ownership was not itself treated as proof of a market role.
The program-owned positive owner was independently classified below.

---

## 9. Pump market-role classification

Pump program:

`6EF8rrecthR5Dkzon8Nwu78hRvfCKubJ14M5uBEwF6P`

BondingCurve account:

`5vVqzHEen5LmiEee7q5kHAigxXaUpyhXN6FNYCngFA9d`

Curve-controlled UTTT token account:

`FEv49NXsBkXf82si16xnPQdaAjGPj7PHUAk22HP9pfj1`

BondingCurve discriminator:

    23,183,248,55,96,216,172,96

Accepted R3A Pump-state observation:

    virtual_token_reserves
    904,755,055.196096 UTTT

    virtual_sol_reserves
    35.578692738 SOL

    real_token_reserves
    624,855,055.196096 UTTT

    real_sol_reserves
    5.578692738 SOL

    token_total_supply
    1,000,000,000 UTTT

    complete
    false

At the accepted observation:

- Pump-owned positive UTTT owners: 1
- PumpSwap-controlled positive UTTT owners: 0
- other non-Pump program-owned positive UTTT owners: 0

Accepted market role:

**INCOMPLETE / PRE-GRADUATION PUMP BONDING CURVE**

No graduated PumpSwap positive-inventory state was observed.

This is a snapshot classification. A later curve completion or
migration would require a new current-state observation.

---

## 10. Creation transaction: gross mint and atomic transfer

The immutable creation transaction was reparsed after separating
instruction-level gross minting from transaction-end token balances.

Gross mint:

    scope=inner:2:12
    type=mintTo
    destination=FEv49NXsBkXf82si16xnPQdaAjGPj7PHUAk22HP9pfj1
    amount=1,000,000,000 UTTT

Therefore the full gross issuance targeted the current Pump
curve-controlled UTTT token account.

The same atomic transaction then contained:

    scope=inner:5:1
    type=transferChecked
    source=FEv49NXsBkXf82si16xnPQdaAjGPj7PHUAk22HP9pfj1
    destination=AfosU1aKr3W4zuUJcS91GDD2XkXmuiHXTKCiBTnuVhXR
    amount=17,376,518.166910 UTTT

Transfer destination token-account owner:

`6Mu6sovSMmHQXacPpTV4cvqm3gsfhw9jgKHXf1mtzxv2`

Creation-transaction balances:

    curve token account
    pre=0
    post=982,623,481.833090
    delta=+982,623,481.833090

    non-curve recipient
    pre=0
    post=17,376,518.166910
    delta=+17,376,518.166910

Transaction-wide supply result:

    gross mint=1,000,000,000
    burns=0
    net supply delta=1,000,000,000

Gross-to-net curve equation:

    1,000,000,000
    - 17,376,518.166910
    =
    982,623,481.833090 UTTT

No off-chain personal identity is attributed to the recipient owner in
this forensic artifact.

---

## 11. Pump accounting reconciliation

Accepted current curve-controlled balance:

`831,755,055.196096 UTTT`

Gross-mint-anchored total curve outflow:

    1,000,000,000
    - 831,755,055.196096
    =
    168,244,944.803904 UTTT

Derived initial real token reserves:

    624,855,055.196096
    + 168,244,944.803904
    =
    793,100,000 UTTT

Derived initial virtual token reserves:

    904,755,055.196096
    + 168,244,944.803904
    =
    1,073,000,000 UTTT

Token-account / real-reserve structural gap:

    831,755,055.196096
    - 624,855,055.196096
    =
    206,900,000 UTTT

Initial structural gap:

    1,000,000,000
    - 793,100,000
    =
    206,900,000 UTTT

Virtual / real token reserve gap:

    904,755,055.196096
    - 624,855,055.196096
    =
    279,900,000 UTTT

Derived initial virtual / real token reserve gap:

    1,073,000,000
    - 793,100,000
    =
    279,900,000 UTTT

Virtual / real SOL reserve gap:

    35.578692738
    - 5.578692738
    =
    30 SOL

Current supply outside the curve:

`168,242,383.462358 UTTT`

Burn-aware conservation:

    168,242,383.462358
    + 2,561.341546
    =
    168,244,944.803904 UTTT
    =
    gross-mint-anchored curve outflow

All accepted Pump accounting invariants reconcile exactly.

---

## 12. Evidence transport and trust boundary

Historical archival evidence transport:

Alchemy Solana archival RPC.

Current complete-account enumeration transport:

Helius Solana Mainnet RPC using paginated `getProgramAccountsV2`
zero-byte discovery plus bounded standard RPC hydration.

Provider role:

**EVIDENCE TRANSPORT ONLY**

Canonical authority:

**SOLANA CHAIN STATE**

Provider secrets:

- are not committed to UTTchain
- are not written into this artifact
- do not constitute protocol authority
- do not constitute canonical state independently of the chain

The existing UTTchain RPC/indexer trust and privacy boundaries remain
unchanged.

---

## 13. Proven boundary

The accepted Solana forensic tranche establishes:

- exact Solana Token-2022 identity
- historical gross issuance of 1B UTTT
- exactly one accepted historical mint event
- eight accepted historical burn events
- 2,561.341546 UTTT total accepted historical burns
- supply reconciliation to 999,997,438.658454 UTTT
- mint-authority retirement to NONE
- freeze authority NONE
- metadata authority retirement
- accepted historical transaction corpus
- complete accepted token-account snapshot
- complete accepted Solana reserve history
- exact +10M then +30M source-reserve provenance
- accepted 40M designated Solana reserve
- Pump BondingCurve classification of the sole program-owned positive owner
- gross 1B creation mint to the Pump curve token account
- atomic 17,376,518.166910 UTTT creation-transaction transfer
- accepted incomplete/pre-graduation Pump state
- zero positive PumpSwap-controlled UTTT inventory at the snapshot
- zero other non-Pump program-controlled positive UTTT inventory
- exact structural, reserve, and burn-aware accounting reconciliation

This Solana freeze does not establish:

- globally canonical UTTT representation
- globally non-overlapping circulating supply
- remote Asset Hub / Hydration backing state
- Counterparty economic state
- final migration or redemption policy
- Robinhood Chain canonicalization
- authority to mint new UTTT
- authorization to burn, bridge, migrate, deploy, or trade

---

## 14. Cross-chain boundary

The accepted 40M Solana reserve is source-side evidence associated with
the previously identified Polkadot bridge activity.

The Solana source-side observation does not prove that corresponding
Asset Hub or Hydration assets are presently circulating, locked,
backed, retired, or economically non-overlapping.

Remote-side reconstruction is deferred to:

`UTTC.1.DOT`

Only after Robinhood Chain, Solana, Polkadot/Asset Hub/Hydration, and
Counterparty have individually been characterized can UTTchain perform
global economic-supply reconciliation.

---

## 15. Canonicality disposition

Solana forensic status:

**FINAL / ACCEPTED**

Solana representation designation:

**FORENSICALLY CHARACTERIZED / ECONOMIC CANONICALITY PENDING**

Global UTTT canonicality:

**UNSELECTED**

This artifact records evidence only.

It performs no token-economic action.

---

## 16. Accepted evidence lineage

This freeze incorporates accepted findings from the Solana forensic
sequence, including:

- `UTTC.1.SOL.R1`
- `UTTC.1.SOL.R2A.R1`
- `UTTC.1.SOL.R2R1B.0`
- `UTTC.1.SOL.R2R1B.1`
- `UTTC.1.SOL.R2R1B.1A`
- `UTTC.1.SOL.R3`
- `UTTC.1.SOL.R3.R1B.0`
- `UTTC.1.SOL.R3.R1B.1`
- `UTTC.1.SOL.R3A`
- `UTTC.1.SOL.R3A.R1A`
- `UTTC.1.SOL.R3A.R1B.R1`

Earlier transport, harness, expectation, and parser false negatives are
superseded by their repaired accepted successor measurements.

---

## 17. Snapshot invariant

This artifact freezes an evidence record, not a permanently static live
market state.

Historical creation, mint, burn, and authority-transition evidence is
chain history.

Holder balances, token-account inventories, bonding-curve reserves,
curve completion state, and program-controlled balances are explicitly
snapshot-qualified.

A later legitimate live-state change does not invalidate this freeze.
A future dependency on changed current state requires a newly identified
observation.

---

## 18. Mutation statement

The accepted Solana forensic tranche authorized no:

- UTTT mint
- UTTT burn
- UTTT transfer
- wallet signing
- bridge execution
- migration
- token deployment
- market trade
- liquidity action
- UTT database mutation

The final freeze gate modifies only the UTTchain Git repository by
adding this forensic evidence artifact and its commit.

---

## Final disposition

    UTTC.1.SOL
    FINAL / ACCEPTED

    SOLANA TOKEN IDENTITY
    FROZEN

    HISTORICAL ISSUANCE
    FROZEN

    HISTORICAL BURN RECONSTRUCTION
    FROZEN THROUGH ACCEPTED CORPUS

    AUTHORITY HISTORY
    FROZEN

    SOLANA SOURCE-RESERVE PROVENANCE
    FROZEN

    ACCEPTED HOLDER SNAPSHOT
    FROZEN AS OBSERVATION

    PUMP MARKET-ROLE CLASSIFICATION
    FROZEN AS OBSERVATION

    GLOBAL UTTT ECONOMIC CANONICALITY
    UNSELECTED

    NEXT
    UTTC.1.DOT
