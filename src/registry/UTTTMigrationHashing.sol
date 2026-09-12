// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

/// @title UTTTMigrationHashing
/// @notice Frozen hashing primitives for canonical UTTT migration identifiers,
///         economic leaves, destination-registration leaves, and global nullifiers.
/// @dev Domain labels are reduced once to bytes32 with keccak256, then every
///      structured identity uses abi.encode. Economic and registration leaves
///      use the frozen double-keccak construction.
library UTTTMigrationHashing {
    bytes32 internal constant MIGRATION_DOMAIN = keccak256("UTTCHAIN_UTTT_MIGRATION_V1");
    bytes32 internal constant ENTITLEMENT_ID_DOMAIN = keccak256("UTTCHAIN_UTTT_ENTITLEMENT_ID_V1");
    bytes32 internal constant ENTITLEMENT_LEAF_DOMAIN = keccak256("UTTCHAIN_UTTT_ENTITLEMENT_LEAF_V1");
    bytes32 internal constant REGISTRATION_LEAF_DOMAIN = keccak256("UTTCHAIN_UTTT_REGISTRATION_LEAF_V1");
    bytes32 internal constant NULLIFIER_DOMAIN = keccak256("UTTCHAIN_UTTT_NULLIFIER_V1");

    uint256 internal constant ROBINHOOD_CHAIN_ID = 4663;

    function migrationDomain() internal pure returns (bytes32) {
        return MIGRATION_DOMAIN;
    }

    function entitlementIdDomain() internal pure returns (bytes32) {
        return ENTITLEMENT_ID_DOMAIN;
    }

    function entitlementLeafDomain() internal pure returns (bytes32) {
        return ENTITLEMENT_LEAF_DOMAIN;
    }

    function registrationLeafDomain() internal pure returns (bytes32) {
        return REGISTRATION_LEAF_DOMAIN;
    }

    function nullifierDomain() internal pure returns (bytes32) {
        return NULLIFIER_DOMAIN;
    }

    function robinhoodChainId() internal pure returns (uint256) {
        return ROBINHOOD_CHAIN_ID;
    }

    function entitlementId(
        bytes32 migrationId,
        uint64 entitlementIndex,
        bytes32 rootedRecordHash
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            ENTITLEMENT_ID_DOMAIN,
            migrationId,
            entitlementIndex,
            rootedRecordHash
        ));
    }

    function economicLeaf(
        bytes32 migrationId,
        bytes32 entitlementId_,
        uint64 amountUnits
    ) internal pure returns (bytes32) {
        bytes32 inner = keccak256(abi.encode(
            ENTITLEMENT_LEAF_DOMAIN,
            migrationId,
            entitlementId_,
            amountUnits
        ));

        return keccak256(bytes.concat(inner));
    }

    function registrationLeaf(
        bytes32 migrationId,
        bytes32 entitlementId_,
        address destination,
        bytes32 sourceControlProofHash,
        uint256 registrationEpoch
    ) internal pure returns (bytes32) {
        bytes32 inner = keccak256(abi.encode(
            REGISTRATION_LEAF_DOMAIN,
            migrationId,
            entitlementId_,
            ROBINHOOD_CHAIN_ID,
            destination,
            sourceControlProofHash,
            registrationEpoch
        ));

        return keccak256(bytes.concat(inner));
    }

    function nullifier(
        bytes32 migrationId,
        bytes32 entitlementId_
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            NULLIFIER_DOMAIN,
            migrationId,
            entitlementId_
        ));
    }
}
