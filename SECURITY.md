# Security Policy

UTTchain is under active development and should be treated as experimental software until explicitly marked **PRODUCTION ACCEPTED**.

## Standing security invariants

- Never commit private keys, seed phrases, exchange API secrets, production credentials, or signing material.
- Never place production secrets in frontend bundles.
- Never publish CEX API credentials on-chain.
- The backend must not silently become the user's blockchain signer.
- Unlimited token approvals are not the default policy.
- Asset authority must bind exact chain and contract identity rather than ticker text alone.
- No silent mainnet broadcast or automatic financial retry after transaction authority becomes uncertain.
- Privileged contract roles, proxies, and upgrade authority must be explicit and reviewed.
- Private financial records should remain off-chain unless a later privacy-preserving proof design explicitly requires otherwise.
- Production deployments must come from committed, reconciled, reviewed source.
- No UTTT migration or canonical-supply transition may occur before multi-chain supply and holder reconciliation.

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
- access control and upgrade authority;
- wallet and transaction authorization;
- approval handling and transaction reconciliation;
- web authentication and authorization;
- multi-user isolation;
- database and secret boundaries;
- RPC/provider trust;
- local CEX execution-agent design;
- UTTT supply/migration accounting.

## Development status

A contract being deployed does not by itself mean UTTchain is launched. A website being online does not by itself authorize production trading. Development-state labels used by this project are:

`CONCEPT → SPECIFIED → IMPLEMENTED → TEST-GREEN → TESTNET DEPLOYED → MAINNET DEPLOYED → ACTIVATED → PRODUCTION ACCEPTED`
