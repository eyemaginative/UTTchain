// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title CanonicalUTTT
/// @notice Fixed-supply canonical Unified Trading Terminal Token for Robinhood Chain.
/// @dev The complete immutable genesis supply is minted once, in the constructor,
///      directly to MigrationVault. There is no post-deployment supply authority.
contract CanonicalUTTT is ERC20 {
    uint256 public constant ROBINHOOD_CHAIN_ID = 4663;
    uint8 public constant CANONICAL_DECIMALS = 6;
    uint256 public constant CANONICAL_GENESIS_SUPPLY = 999_997_438_658_454;

    error WrongChain(uint256 actualChainId);
    error ZeroMigrationVault();

    constructor(address migrationVault)
        ERC20("Unified Trading Terminal Token", "UTTT")
    {
        if (block.chainid != ROBINHOOD_CHAIN_ID) {
            revert WrongChain(block.chainid);
        }
        if (migrationVault == address(0)) revert ZeroMigrationVault();

        _mint(migrationVault, CANONICAL_GENESIS_SUPPLY);
    }

    function decimals() public pure override returns (uint8) {
        return CANONICAL_DECIMALS;
    }
}
