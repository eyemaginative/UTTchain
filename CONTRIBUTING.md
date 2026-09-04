# Contributing to UTTchain

UTTchain is currently in a controlled foundation and architecture phase. Contributions should preserve the project's security boundaries and gated development process.

## Before contributing

- Read `README.md` and `SECURITY.md`.
- Do not submit secrets, private keys, seed phrases, API credentials, or private user financial data.
- Do not introduce automatic signing, unlimited approvals, silent mainnet broadcasts, or undocumented privileged roles.
- Do not treat token symbols as canonical asset identity without exact chain/contract binding.
- Do not represent planned functionality as deployed, live, activated, or production accepted.

## Development expectations

Smart-contract work should be developed and reviewed through a test-first lifecycle:

1. specification;
2. local implementation;
3. unit tests;
4. fuzz/invariant tests where appropriate;
5. static analysis;
6. fork/read-only integration where appropriate;
7. Robinhood Chain testnet;
8. deployment/runtime reconciliation;
9. production security review;
10. explicit mainnet authorization.

Application-layer changes must preserve authentication, authorization, tenant isolation, credential boundaries, wallet authority, and transaction-reconciliation semantics.

## Pull requests

Keep changes narrowly scoped and document:

- what changed;
- why it changed;
- affected security/trust boundaries;
- tests performed;
- whether any deployment, token, market, migration, signing, or broadcast authority changes.

Mainnet deployment and financial actions require separate explicit authorization and are not implied by code review or merge.

## UTTT canonical supply

UTTT currently has known economic surfaces on Robinhood Chain, Solana, the Polkadot ecosystem, and Counterparty. Do not introduce a canonical-supply or migration assumption until the multi-chain forensic and holder-state reconciliation phases are accepted.
