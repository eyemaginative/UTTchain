# Security Policy

UTTchain is under active development and should be treated as experimental software until explicitly marked **PRODUCTION ACCEPTED**.

## Standing security invariants

- Never commit private keys, seed phrases, exchange API secrets, production credentials, or signing material.
- Never place production secrets in frontend bundles.
- Never publish CEX API credentials on-chain.
- Hosted UTTchain infrastructure must not silently become the user's blockchain signer.
- UTTchain launch/core protocol use must not require a user-operated local server, daemon, or companion machine.
- UTTchain launch/core protocol use must not require a project-operated application server; optional hosted services may be added later only as explicitly scoped extensions.
- Optional hosted/serverless services must not silently replace canonical on-chain state or authority.
- Unlimited token approvals are not the default policy.
- Asset authority must bind exact chain and contract identity rather than ticker text alone.
- No silent mainnet broadcast or automatic financial retry after transaction authority becomes uncertain.
- Privileged contract roles, proxies, and upgrade authority must be explicit and reviewed.
- Upgradeability is not a blanket requirement. Each upgradeable component must demonstrate a concrete need and have bounded, documented authority.
- Critical token/supply authority must not become upgradeable merely for architectural convenience.
- Private financial records should remain off-chain unless a later privacy-preserving proof design explicitly requires otherwise.
- Production deployments must come from committed, reconciled, reviewed source.
- No UTTT migration or canonical-supply transition may occur before multi-chain supply and holder reconciliation.

## Upgradeability and post-launch services

UTTchain is designed to support future evolution without making every launch component mutable.

Preferred evolution order:

1. add browser/server capabilities without modifying canonical contracts where possible;
2. add new versioned or modular contracts when on-chain functionality must evolve;
3. explicitly migrate or supersede immutable components where safe;
4. use proxy-based upgrades only for components whose accepted specification requires them.

Any upgradeable component must define and test:

- upgrade authority and any multisig/timelock boundary;
- storage-layout compatibility;
- initialization/reinitialization safety;
- upgrade and rollback/recovery behavior;
- deployment and runtime reconciliation;
- event/version visibility;
- migration behavior for state, balances, or integrations where applicable.

Optional hosted/serverless services introduced after launch must be treated as separate trust boundaries. Their outage, compromise, or removal must not silently rewrite canonical on-chain state or acquire user signing authority.

## Reporting a vulnerability

Do not publish exploitable security issues, secrets, or active attack details in a public issue.

Until a dedicated private disclosure channel is published, contact the repository owner through an appropriate private channel and provide:

- affected component/version or commit;
- impact summary;
- reproduction steps or proof of concept where safe;
- affected chain/network if applicable;
- whether funds, credentials, or user data may be at risk;
- recommended mitigation if known.

## Scope

Security review for UTTchain covers both smart-contract and application boundaries, including:

- Solidity contracts and deployment scripts;
- access control and bounded upgrade authority;
- proxy/storage-layout safety where upgradeability is used;
- wallet and transaction authorization;
- approval handling and transaction reconciliation;
- browser security and wallet integration;
- optional hosted/serverless service boundaries;
- authorization and isolation for any optional hosted state;
- database and secret boundaries where services exist;
- RPC/provider, indexer, and oracle trust;
- CEX integration/service boundaries without mandatory local UTTchain infrastructure;
- UTTT supply/migration accounting.

## Development status

A contract being deployed does not by itself mean UTTchain is launched. A website or optional server being online does not by itself authorize production trading or alter canonical protocol authority. Development-state labels used by this project are:

`CONCEPT → SPECIFIED → IMPLEMENTED → TEST-GREEN → TESTNET DEPLOYED → MAINNET DEPLOYED → ACTIVATED → PRODUCTION ACCEPTED`
