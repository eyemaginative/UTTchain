# UTTT Counterparty Forensic Freeze

## Status

**FINAL / ACCEPTED**

This document freezes the accepted Counterparty forensic record for Unified Trading Terminal Token (UTTT) within UTTchain.

It records Counterparty asset identity, native issuance chronology, Bitcoin anchoring, metadata history, current holder and market state, administrative issuance authority, and the accepted cross-domain economic classification established by `UTTC.1.XCP`.

This artifact does **not** select the globally canonical UTTT economic representation. Global canonicality remains deferred until Robinhood Chain, Solana, Polkadot / Asset Hub / Hydration, and Counterparty are reconciled together.

No token issuance, burn, destruction, lock, transfer, migration, bridge execution, wallet signing, Bitcoin broadcast, or market action is authorized by this freeze.

---

## 1. Counterparty identity

- Network: Counterparty mainnet
- Settlement / data-availability anchor: Bitcoin mainnet
- Asset: `UTTT`
- Current description: `Unified Trading Terminal Token`
- Divisibility: `false`
- Current accepted supply: `40,000,000 UTTT`
- Current issuer: `166z4asq1si1vamuvLoSe6qSjDJDhkEGw1`
- Current owner: `166z4asq1si1vamuvLoSe6qSjDJDhkEGw1`
- Current asset lock: `false`

Counterparty quantity units are whole UTTT units for this indivisible asset.

The issuer and owner are the same address at the accepted observation point. That establishes an on-chain role relationship only; it does not prove a treasury designation, beneficial ownership, private-key controller, or immutable custody arrangement.

---

## 2. Native Counterparty creation

UTTT was created natively on Counterparty through an issuance message.

- Genesis Bitcoin block: `958075`
- Genesis UTC: `2026-07-14T22:55:31Z`
- Genesis Bitcoin / Counterparty transaction: `6c5b7f36ddf01c1576fec909fdfa92baf6f5338679e3dd925d0d2d929876719e`
- Bitcoin block hash: `00000000000000000001cdda4021a164a0051b248b8b24c4ee1530bad5a1e245`
- Counterparty message type: `issuance`
- Message type ID: `22`
- Genesis quantity: `40,000,000 UTTT`
- Genesis description: `Unfied Trading Terminal Token`

The historical spelling above is preserved exactly as committed in the genesis issuance payload.

Accepted evidence fingerprints:

- Genesis Counterparty transaction JSON SHA256: `f70313687a4adcdbb2496badb6d58f5136ded468f693646caf3f022e3b410597`
- `ASSET_CREATION` event index: `20243161`
- `ASSET_CREATION` event JSON SHA256: `a96ff467ea11b8cf191960733f31cc03e3bb973479970ff1806857a43c33b168`
- `ASSET_ISSUANCE` event index: `20243162`
- `ASSET_ISSUANCE` event JSON SHA256: `0680a52989b828d777792815fa4e5b5358de2cf5028bd165446a68656d72fab8`

Accepted chain-origin classification:

`NATIVE_COUNTERPARTY_ASSET_CREATION`

---

## 3. Independent Bitcoin genesis anchor

The genesis transaction was independently rebound to Bitcoin block 958075.

- Accepted Bitcoin transaction JSON SHA256: `34ba401a5a7eef48eb892c208e76f8768352bb2e364cfc49c0195204ca3c2cbf`
- Accepted Bitcoin block JSON SHA256: `77b60a3291d422ac50c57d6b93c43584305a386aab5f48385f9477031d73caf9`

The Counterparty genesis record and independent Bitcoin lookup produced the same transaction identity, height, block hash, and block time.

---

## 4. Description correction

The second and only later accepted issuance-history row changed the description without changing quantity.

- Bitcoin / Counterparty block: `965979`
- UTC: `2026-09-07T22:18:08Z`
- Transaction: `279bd963aeeeecfde4f5e914551ca9440f568cfd6a68672d13c8321af3a14311`
- Bitcoin block hash: `0000000000000000000021cf9e6104d9f6e6ba93891de142ae0a94f66b1bc851`
- Counterparty message type: `issuance`
- Message type ID: `22`
- Quantity: `0`
- Asset event: `change_description`
- Prior description: `Unfied Trading Terminal Token`
- New / current description: `Unified Trading Terminal Token`
- Accepted Counterparty transaction JSON SHA256: `654255cf35a6f1198979ed52d789d7d79cc7fcfeeab73207398803e3bcb3f7b1`
- Accepted `ASSET_ISSUANCE` event index: `20535699`
- Accepted event JSON SHA256: `92ac7d8b222821b19cb748b9e4a9e2b4ec94f679b901295bd64b3078fa0bdd81`

The description transaction reached the accepted minimum six-Bitcoin-confirmation forensic depth before `UTTC.1.XCP.R1` was closed.

---

## 5. Independent Bitcoin metadata anchor

The description-update transaction was independently rebound to Bitcoin block 965979.

- Accepted Bitcoin transaction JSON SHA256: `5c8e21c95b70f7ef8cae4b6f5abe1136cb330e7afd57150d5381f22a57320b7c`
- Accepted Bitcoin block JSON SHA256: `93fafe2f6f5916f99e8d572d144a498056bccbe2d1d375c34feb91735eba4c33`

The Counterparty record and independent Bitcoin evidence agree on transaction, height, block hash, and block time. The second issuance-history row is therefore accepted as a zero-quantity metadata correction, not an additional supply issuance.

---

## 6. Complete accepted quantity chronology

The complete accepted Counterparty issuance history contains exactly two rows:

1. Native creation: quantity 40,000,000; asset event `creation`; block 958075.
2. Description correction: quantity 0; asset event `change_description`; block 965979.

Exactly one accepted issuance row has positive quantity.

Quantity reconciliation:

    40,000,000  native creation
    +        0  description change
    -----------
    40,000,000  current Counterparty supply

No accepted quantity increase beyond the genesis 40M was observed.

---

## 7. Supply-mutation and authority chronology

The accepted complete Counterparty history establishes:

- destruction records: 0
- fairminter records: 0
- fairmint records: 0
- lock event: none observed
- issuer transfer: none observed
- reset: none observed
- current locked state: false

The current quantity-issuance authority remains live.

The current 40M supply is **not** frozen as an immutable or permanently capped Counterparty supply. A later explicit quantity lock or other administrative action would be a subsequent state transition and would require new evidence.

---

## 8. Current holder state

- Accepted current holder count: `1`
- Accepted sole holder: `166z4asq1si1vamuvLoSe6qSjDJDhkEGw1`
- Accepted holder quantity: `40,000,000 UTTT`
- Accepted role classification: `ISSUER_OWNER_LINKED_CUSTODY`

The complete current Counterparty UTTT supply resides in the same address that currently occupies issuer and owner roles.

This classification does not assert treasury ownership, beneficial ownership, identity of a private-key controller, multisignature or single-signature custody, permanence of custody, or bridge-escrow semantics.

---

## 9. Current market state

At the accepted observation:

- open Counterparty UTTT orders: 0
- open Counterparty UTTT dispensers: 0

No live Counterparty market inventory was established by the accepted forensic measurement. This is an observation snapshot, not a claim that future orders or dispensers are impossible.

---

## 10. Relationship to Solana and Asset Hub

The accepted Solana / Polkadot forensic record already establishes a single 40M remote accounting line:

    40,000,000 Solana designated reserve
    =
    40,000,000 Asset Hub remote economic line

Hydration is contained within the Asset Hub line and is not additive economic supply.

The accepted Solana designated reserve chronology is:

- +10M on 2026-05-25T16:23:09Z
- +30M on 2026-07-01T05:27:50Z

The reserve reached 40M on `2026-07-01T05:27:50Z`.

Counterparty's separate native 40M creation occurred on `2026-07-14T22:55:31Z`, 13 days, 17 hours, 27 minutes, and 41 seconds later.

The accepted evidence found:

- no Solana burn associated with Counterparty creation
- no decrease in the designated Solana 40M reserve
- no accepted Asset Hub burn associated with Counterparty creation
- no Counterparty destruction associated with migration
- no Counterparty lock associated with migration
- no Counterparty issuer transfer associated with migration
- no Counterparty reset associated with migration
- no explicit bridge evidence binding XCP 40M non-additively to the already-accounted Solana / Asset Hub 40M line

The numerical equality of XCP 40M, Asset Hub 40M, and the designated Solana reserve 40M is accepted as **non-causal numerical equality** for current forensic purposes. Numerical equality alone is not bridge proof.

---

## 11. Cross-domain economic classification

`UTTC.1.XCP.R2` accepted:

- Chain origin: `NATIVE_COUNTERPARTY_ASSET_CREATION`
- Cross-domain origin: `NO_PROVEN_SOURCE_EXTINGUISHMENT`
- Relation to existing Solana / Asset Hub 40M line: `NUMERICALLY_EQUAL_40M_BUT_NONCAUSAL`
- Economic class: `INDEPENDENT_LIVE_SUPPLY_PENDING_CANONICALIZATION`
- Accounting treatment: `ADDITIVE_FOR_RECONCILIATION`

This is a conservative forensic accounting classification. It does not assert the original human intent behind creating the Counterparty asset.

Absent proof of extinguishment, reserve release, or an explicit non-additive bridge relation, the Counterparty 40M must not be silently netted against an already-accounted remote line.

---

## 12. SOL / DOT / XCP reconciliation boundary

Accepted values:

- Solana current supply: `999,997,438.658454 UTTT`
- Designated Solana reserve: `40,000,000 UTTT`
- Solana supply outside that reserve: `959,997,438.658454 UTTT`
- Asset Hub remote economic line: `40,000,000 UTTT`

Therefore:

    959,997,438.658454  Solana outside designated reserve
    +40,000,000.000000  Asset Hub remote line
    -------------------
    999,997,438.658454  SOL + DOT economic amount

Counterparty is additive under the accepted current classification:

    999,997,438.658454  SOL + DOT economic amount
    +40,000,000.000000  independent-live Counterparty amount
    -------------------
    1,039,997,438.658454  SOL + DOT + XCP economic amount

**1,039,997,438.658454 UTTT is not declared the global canonical supply.**

Robinhood Chain remains part of the final global reconciliation. The arithmetic above is a forensic reconciliation boundary, not a tokenomics authorization.

---

## 13. Counterparty forensic designation

The accepted Counterparty record is:

- identity: established
- native creation: established
- native creation Bitcoin anchor: established
- description-update chronology: established
- description-update Bitcoin anchor: established
- quantity history: established
- current supply: established
- current holder state: established
- destruction history: none observed
- fairminter / fairmint history: none observed
- issuer-transfer history: none observed
- reset history: none observed
- current quantity lock: false
- current issuance authority: live
- current market surface: empty at accepted observation
- relation to SOL / Asset Hub 40M: numerical but non-causal
- economic treatment: additive for reconciliation
- global canonicality: not selected

Designation:

**INDEPENDENT LIVE COUNTERPARTY REPRESENTATION PENDING GLOBAL CANONICALIZATION**

---

## 14. Global-canonicality boundary

This Counterparty freeze does not decide which UTTT representation ultimately survives as canonical.

The next global reconciliation must consider together Robinhood Chain nominal UTTT, Solana UTTT, Solana designated reserves, Asset Hub remote UTTT, Hydration contained representation, Counterparty native UTTT, authority state, provable burns and locks, migration obligations, economic duplication, and holder obligations.

The global process must distinguish nominal chain supply from economic supply. No representation becomes globally canonical merely because it carries the UTTT name or symbol.

---

## 15. Authorization status

- Global UTTT canonical supply: **NOT YET SELECTED**
- Global UTTT canonical contract: **NOT YET SELECTED**
- Counterparty 40M lock: **NOT AUTHORIZED**
- Counterparty additional issuance: **NOT AUTHORIZED**
- Counterparty destruction: **NOT AUTHORIZED**
- Counterparty issuer transfer: **NOT AUTHORIZED**
- Counterparty migration / retirement: **NOT AUTHORIZED**
- Solana migration / retirement: **NOT AUTHORIZED**
- Asset Hub migration / retirement: **NOT AUTHORIZED**
- Robinhood Chain migration / retirement: **NOT AUTHORIZED**
- New UTTT deployment: **NOT AUTHORIZED**
- UTTT mint: **NOT AUTHORIZED**
- UTTT burn: **NOT AUTHORIZED**
- Bridge execution: **NOT AUTHORIZED**
- Wallet signing / Bitcoin broadcast: **NOT AUTHORIZED**
- Market action: **NOT AUTHORIZED**

---

## 16. Next forensic boundary

Counterparty forensic work is complete for the accepted current evidence.

Next: `UTTC.1.FINAL`

Purpose: perform the global Robinhood Chain + Solana + Asset Hub / Hydration + Counterparty economic reconciliation and select the canonical UTTT economic model before any migration, retirement, lock, burn, or new deployment is designed or authorized.
