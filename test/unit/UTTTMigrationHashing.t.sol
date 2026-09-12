// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Test} from "forge-std/Test.sol";
import {UTTTMigrationHashing} from "../../src/registry/UTTTMigrationHashing.sol";

contract UTTTMigrationHashingHarness {
    function migrationDomain() external pure returns (bytes32) {
        return UTTTMigrationHashing.migrationDomain();
    }

    function entitlementIdDomain() external pure returns (bytes32) {
        return UTTTMigrationHashing.entitlementIdDomain();
    }

    function entitlementLeafDomain() external pure returns (bytes32) {
        return UTTTMigrationHashing.entitlementLeafDomain();
    }

    function registrationLeafDomain() external pure returns (bytes32) {
        return UTTTMigrationHashing.registrationLeafDomain();
    }

    function nullifierDomain() external pure returns (bytes32) {
        return UTTTMigrationHashing.nullifierDomain();
    }

    function robinhoodChainId() external pure returns (uint256) {
        return UTTTMigrationHashing.robinhoodChainId();
    }

    function entitlementId(
        bytes32 migrationId,
        uint64 entitlementIndex,
        bytes32 rootedRecordHash
    ) external pure returns (bytes32) {
        return UTTTMigrationHashing.entitlementId(
            migrationId,
            entitlementIndex,
            rootedRecordHash
        );
    }

    function economicLeaf(
        bytes32 migrationId,
        bytes32 entitlementId_,
        uint64 amountUnits
    ) external pure returns (bytes32) {
        return UTTTMigrationHashing.economicLeaf(
            migrationId,
            entitlementId_,
            amountUnits
        );
    }

    function registrationLeaf(
        bytes32 migrationId,
        bytes32 entitlementId_,
        address destination,
        bytes32 sourceControlProofHash,
        uint256 registrationEpoch
    ) external pure returns (bytes32) {
        return UTTTMigrationHashing.registrationLeaf(
            migrationId,
            entitlementId_,
            destination,
            sourceControlProofHash,
            registrationEpoch
        );
    }

    function nullifier(
        bytes32 migrationId,
        bytes32 entitlementId_
    ) external pure returns (bytes32) {
        return UTTTMigrationHashing.nullifier(
            migrationId,
            entitlementId_
        );
    }
}

contract UTTTMigrationHashingTest is Test {
    UTTTMigrationHashingHarness internal harness;

    bytes32 internal constant MIGRATION_ID = keccak256("UTTCHAIN_TEST_MIGRATION_ID");
    bytes32 internal constant ROOTED_RECORD_HASH = keccak256("UTTCHAIN_TEST_ROOTED_RECORD");
    bytes32 internal constant SOURCE_CONTROL_PROOF_HASH = keccak256("UTTCHAIN_TEST_SOURCE_CONTROL_PROOF");

    uint64 internal constant ENTITLEMENT_INDEX = 42;
    uint64 internal constant AMOUNT_UNITS = 123_456_789;
    uint256 internal constant REGISTRATION_EPOCH = 7;
    address internal constant DESTINATION = 0x1234567890123456789012345678901234567890;

    function setUp() public {
        harness = new UTTTMigrationHashingHarness();
    }

    function test_domainConstantsMatchFrozenLabels() public view {
        assertEq(harness.migrationDomain(), keccak256("UTTCHAIN_UTTT_MIGRATION_V1"));
        assertEq(harness.entitlementIdDomain(), keccak256("UTTCHAIN_UTTT_ENTITLEMENT_ID_V1"));
        assertEq(harness.entitlementLeafDomain(), keccak256("UTTCHAIN_UTTT_ENTITLEMENT_LEAF_V1"));
        assertEq(harness.registrationLeafDomain(), keccak256("UTTCHAIN_UTTT_REGISTRATION_LEAF_V1"));
        assertEq(harness.nullifierDomain(), keccak256("UTTCHAIN_UTTT_NULLIFIER_V1"));
    }

    function test_robinhoodChainIdIsFrozen() public view {
        assertEq(harness.robinhoodChainId(), 4663);
    }

    function test_entitlementIdMatchesFrozenAbiEncoding() public view {
        bytes32 expected = keccak256(abi.encode(
            keccak256("UTTCHAIN_UTTT_ENTITLEMENT_ID_V1"),
            MIGRATION_ID,
            ENTITLEMENT_INDEX,
            ROOTED_RECORD_HASH
        ));

        assertEq(
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH),
            expected
        );
    }

    function test_economicLeafMatchesFrozenDoubleKeccak() public view {
        bytes32 entitlementId_ =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH);

        bytes32 inner = keccak256(abi.encode(
            keccak256("UTTCHAIN_UTTT_ENTITLEMENT_LEAF_V1"),
            MIGRATION_ID,
            entitlementId_,
            AMOUNT_UNITS
        ));

        assertEq(
            harness.economicLeaf(MIGRATION_ID, entitlementId_, AMOUNT_UNITS),
            keccak256(bytes.concat(inner))
        );
    }

    function test_registrationLeafMatchesFrozenDoubleKeccak() public view {
        bytes32 entitlementId_ =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH);

        bytes32 inner = keccak256(abi.encode(
            keccak256("UTTCHAIN_UTTT_REGISTRATION_LEAF_V1"),
            MIGRATION_ID,
            entitlementId_,
            uint256(4663),
            DESTINATION,
            SOURCE_CONTROL_PROOF_HASH,
            REGISTRATION_EPOCH
        ));

        assertEq(
            harness.registrationLeaf(
                MIGRATION_ID,
                entitlementId_,
                DESTINATION,
                SOURCE_CONTROL_PROOF_HASH,
                REGISTRATION_EPOCH
            ),
            keccak256(bytes.concat(inner))
        );
    }

    function test_nullifierMatchesFrozenAbiEncoding() public view {
        bytes32 entitlementId_ =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH);

        bytes32 expected = keccak256(abi.encode(
            keccak256("UTTCHAIN_UTTT_NULLIFIER_V1"),
            MIGRATION_ID,
            entitlementId_
        ));

        assertEq(harness.nullifier(MIGRATION_ID, entitlementId_), expected);
    }

    function test_entitlementIdChangesWithIndex() public view {
        bytes32 first =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH);
        bytes32 second =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX + 1, ROOTED_RECORD_HASH);

        assertNotEq(first, second);
    }

    function test_economicLeafChangesWithAmount() public view {
        bytes32 entitlementId_ =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH);

        bytes32 first =
            harness.economicLeaf(MIGRATION_ID, entitlementId_, AMOUNT_UNITS);
        bytes32 second =
            harness.economicLeaf(MIGRATION_ID, entitlementId_, AMOUNT_UNITS + 1);

        assertNotEq(first, second);
    }

    function test_registrationLeafChangesWithDestination() public view {
        bytes32 entitlementId_ =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH);

        bytes32 first = harness.registrationLeaf(
            MIGRATION_ID,
            entitlementId_,
            DESTINATION,
            SOURCE_CONTROL_PROOF_HASH,
            REGISTRATION_EPOCH
        );
        bytes32 second = harness.registrationLeaf(
            MIGRATION_ID,
            entitlementId_,
            address(0xBEEF),
            SOURCE_CONTROL_PROOF_HASH,
            REGISTRATION_EPOCH
        );

        assertNotEq(first, second);
    }

    function test_registrationLeafChangesWithEpoch() public view {
        bytes32 entitlementId_ =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH);

        bytes32 first = harness.registrationLeaf(
            MIGRATION_ID,
            entitlementId_,
            DESTINATION,
            SOURCE_CONTROL_PROOF_HASH,
            REGISTRATION_EPOCH
        );
        bytes32 second = harness.registrationLeaf(
            MIGRATION_ID,
            entitlementId_,
            DESTINATION,
            SOURCE_CONTROL_PROOF_HASH,
            REGISTRATION_EPOCH + 1
        );

        assertNotEq(first, second);
    }

    function test_domainSeparatedHashesDoNotCollideForSameCoreInputs() public view {
        bytes32 entitlementId_ =
            harness.entitlementId(MIGRATION_ID, ENTITLEMENT_INDEX, ROOTED_RECORD_HASH);

        bytes32 economic =
            harness.economicLeaf(MIGRATION_ID, entitlementId_, AMOUNT_UNITS);
        bytes32 registration = harness.registrationLeaf(
            MIGRATION_ID,
            entitlementId_,
            DESTINATION,
            SOURCE_CONTROL_PROOF_HASH,
            REGISTRATION_EPOCH
        );
        bytes32 nullifier_ = harness.nullifier(MIGRATION_ID, entitlementId_);

        assertNotEq(economic, registration);
        assertNotEq(economic, nullifier_);
        assertNotEq(registration, nullifier_);
    }

    function testFuzz_entitlementIdMatchesReference(
        bytes32 migrationId,
        uint64 entitlementIndex,
        bytes32 rootedRecordHash
    ) public view {
        bytes32 expected = keccak256(abi.encode(
            keccak256("UTTCHAIN_UTTT_ENTITLEMENT_ID_V1"),
            migrationId,
            entitlementIndex,
            rootedRecordHash
        ));

        assertEq(
            harness.entitlementId(migrationId, entitlementIndex, rootedRecordHash),
            expected
        );
    }

    function testFuzz_economicLeafMatchesReference(
        bytes32 migrationId,
        bytes32 entitlementId_,
        uint64 amountUnits
    ) public view {
        bytes32 inner = keccak256(abi.encode(
            keccak256("UTTCHAIN_UTTT_ENTITLEMENT_LEAF_V1"),
            migrationId,
            entitlementId_,
            amountUnits
        ));

        assertEq(
            harness.economicLeaf(migrationId, entitlementId_, amountUnits),
            keccak256(bytes.concat(inner))
        );
    }

    function testFuzz_registrationLeafMatchesReference(
        bytes32 migrationId,
        bytes32 entitlementId_,
        address destination,
        bytes32 sourceControlProofHash,
        uint256 registrationEpoch
    ) public view {
        bytes32 inner = keccak256(abi.encode(
            keccak256("UTTCHAIN_UTTT_REGISTRATION_LEAF_V1"),
            migrationId,
            entitlementId_,
            uint256(4663),
            destination,
            sourceControlProofHash,
            registrationEpoch
        ));

        assertEq(
            harness.registrationLeaf(
                migrationId,
                entitlementId_,
                destination,
                sourceControlProofHash,
                registrationEpoch
            ),
            keccak256(bytes.concat(inner))
        );
    }

    function testFuzz_nullifierMatchesReference(
        bytes32 migrationId,
        bytes32 entitlementId_
    ) public view {
        bytes32 expected = keccak256(abi.encode(
            keccak256("UTTCHAIN_UTTT_NULLIFIER_V1"),
            migrationId,
            entitlementId_
        ));

        assertEq(harness.nullifier(migrationId, entitlementId_), expected);
    }
}
