# UTTchain Implementation Toolchain Freeze

## Status

**UTTC.3.R0B.R1.R1 — FINAL / ACCEPTED after successful gate completion**

This artifact freezes the UTTchain implementation toolchain after the canonical migration architecture freeze.

## Foundry

Version: 1.8.1
Upstream tag commit: 982849d3140c01fd3b72905759581a132df7aa98
Windows AMD64 archive SHA256: 02d98fc2c573793960ee06b7f642487d483fe30572f7e248804c207334a418d8

UTTchain uses a project-isolated versioned Foundry runtime.
The user-global .foundry/bin installation is not UTTchain authority and is not overwritten.

Authenticated executable SHA256 values:

- forge.exe: bbebdc0cb44e752228d572681300b5ece5420ea08ad17fa56474a36703f2370a
- cast.exe: 57f1a94156dc634869586c6a8a78bcbdecf2bd1d6614e6edaaf1a7dc44bce73d
- anvil.exe: c6e29da1b010fe00bac6c0dc5c29484bd641deb5a84050aea10d13e9dc4fe26f
- chisel.exe: 656a0ccf98448d574ffc9091ef8ae54df43da2de1bbb9331f258c3b64a272288

## Solidity

Compiler: 0.8.36+commit.8a079791
Upstream tag commit: 8a079791d9cca7a6c03fd6a8429b93aa3bddefed
Windows AMD64 compiler SHA256: 38cf5df656da822cf88b854cf736475a196c679f4f5f3f15ddd8c85ce5dbb36a
EVM target: cancun

Compiler configuration:

- optimizer = true
- optimizer_runs = 200
- via_ir = false
- ffi = false
- auto_detect_solc = false
- auto_detect_remappings = false
- bytecode_hash = ipfs
- use_literal_content = true

## Robinhood Chain capability witness

Chain ID: 4663
Observed block: 58846448
Observed block hash: 0x67cd6f1b974a18afa9e7f08e8ad68902f8e366c364fdd7ef2387b5bf13eabe7b
ArbSys arbOSVersion(): 116
Derived ArbOS internal version: 61

Accepted read-only execution probes:

- baseline creation code
- Shanghai PUSH0
- Cancun MCOPY
- Cancun TSTORE/TLOAD
- Osaka CLZ additionally observed but not required

Cancun is the frozen UTTchain V1 execution floor.

## Dependencies

OpenZeppelin Contracts: v5.7.0
OpenZeppelin exact commit: cab19933c33c2ad1d4c7a84864a3601dddfd16f3
forge-std: v1.16.2
forge-std exact commit: bf647bd6046f2f7da30d0c2bf435e5c76a780c1b

Dependencies are represented by exact Git submodule gitlinks and foundry.lock state.
Floating branch dependencies are not accepted.
openzeppelin-contracts-upgradeable is not part of minimal V1.

## Source boundary

No tracked UTTchain Solidity source existed when this toolchain freeze was established.
CREATE2 component identities remain deferred until implementation source and constructor inputs are accepted.
Reviewer identities remain deferred to the deployment-input freeze.

## Authorization boundary

This freeze authorizes implementation work only.
It does not authorize deployment, legacy mutation, registration-root activation, migration claims, bridge actions, or market actions.
