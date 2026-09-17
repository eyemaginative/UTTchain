// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Test} from "forge-std/Test.sol";

import {RegistrationRootRegistry} from "../../src/registry/RegistrationRootRegistry.sol";
import {RetirementSink} from "../../src/settlement/RetirementSink.sol";
import {CanonicalUTTT} from "../../src/token/CanonicalUTTT.sol";
import {MigrationVault} from "../../src/token/MigrationVault.sol";
import {UTTchainGenesisFactory} from "../../src/execution/UTTchainGenesisFactory.sol";

contract RevertingGenesisComponent {
    constructor() {
        revert();
    }
}

contract UTTchainGenesisFactoryTest is Test {
    uint256 internal constant RH_CHAIN_ID = 4663;
    uint64 internal constant GENESIS_AMOUNT = 999_997_438_658_454;

    bytes32 internal constant MIGRATION_ID = keccak256("UTTCHAIN_R6_MIGRATION_TEST");
    bytes32 internal constant ECONOMIC_ROOT = keccak256("UTTCHAIN_R6_ECONOMIC_ROOT_TEST");
    bytes32 internal constant MANIFEST_HASH = keccak256("UTTCHAIN_R6_DEPLOYMENT_MANIFEST_TEST");

    address[5] internal reviewers;
    UTTchainGenesisFactory internal factory;

    function setUp() public {
        vm.chainId(RH_CHAIN_ID);
        reviewers = _reviewers();
        factory = _newFactory(
            reviewers,
            keccak256(type(RegistrationRootRegistry).creationCode),
            keccak256(type(MigrationVault).creationCode),
            keccak256(type(RetirementSink).creationCode),
            keccak256(type(CanonicalUTTT).creationCode)
        );
    }

    function test_constantsAndConfigurationExact() public view {
        assertEq(factory.ROBINHOOD_CHAIN_ID(), RH_CHAIN_ID);
        assertEq(factory.CANONICAL_GENESIS_AMOUNT(), GENESIS_AMOUNT);
        assertEq(factory.DEPLOYMENT_DOMAIN(), keccak256("UTTCHAIN_UTTT_DEPLOYMENT_V1"));
        assertEq(factory.migrationId(), MIGRATION_ID);
        assertEq(factory.economicRoot(), ECONOMIC_ROOT);
        assertEq(factory.deploymentManifestHash(), MANIFEST_HASH);
        assertEq(factory.registryCreationCodeHash(), keccak256(type(RegistrationRootRegistry).creationCode));
        assertEq(factory.vaultCreationCodeHash(), keccak256(type(MigrationVault).creationCode));
        assertEq(factory.sinkCreationCodeHash(), keccak256(type(RetirementSink).creationCode));
        assertEq(factory.tokenCreationCodeHash(), keccak256(type(CanonicalUTTT).creationCode));
    }

    function test_constructorRejectsWrongChain() public {
        vm.chainId(1);
        vm.expectRevert(abi.encodeWithSelector(UTTchainGenesisFactory.WrongChain.selector, uint256(1)));
        _newFactory(
            reviewers,
            keccak256(type(RegistrationRootRegistry).creationCode),
            keccak256(type(MigrationVault).creationCode),
            keccak256(type(RetirementSink).creationCode),
            keccak256(type(CanonicalUTTT).creationCode)
        );
    }

    function test_constructorRejectsZeroMigrationId() public {
        vm.expectRevert(UTTchainGenesisFactory.ZeroMigrationId.selector);
        new UTTchainGenesisFactory(
            bytes32(0),
            ECONOMIC_ROOT,
            MANIFEST_HASH,
            reviewers,
            keccak256(type(RegistrationRootRegistry).creationCode),
            keccak256(type(MigrationVault).creationCode),
            keccak256(type(RetirementSink).creationCode),
            keccak256(type(CanonicalUTTT).creationCode)
        );
    }

    function test_constructorRejectsZeroEconomicRoot() public {
        vm.expectRevert(UTTchainGenesisFactory.ZeroEconomicRoot.selector);
        new UTTchainGenesisFactory(
            MIGRATION_ID,
            bytes32(0),
            MANIFEST_HASH,
            reviewers,
            keccak256(type(RegistrationRootRegistry).creationCode),
            keccak256(type(MigrationVault).creationCode),
            keccak256(type(RetirementSink).creationCode),
            keccak256(type(CanonicalUTTT).creationCode)
        );
    }

    function test_constructorRejectsZeroManifestHash() public {
        vm.expectRevert(UTTchainGenesisFactory.ZeroDeploymentManifestHash.selector);
        new UTTchainGenesisFactory(
            MIGRATION_ID,
            ECONOMIC_ROOT,
            bytes32(0),
            reviewers,
            keccak256(type(RegistrationRootRegistry).creationCode),
            keccak256(type(MigrationVault).creationCode),
            keccak256(type(RetirementSink).creationCode),
            keccak256(type(CanonicalUTTT).creationCode)
        );
    }

    function test_constructorRejectsZeroReviewer() public {
        address[5] memory invalid = reviewers;
        invalid[3] = address(0);
        vm.expectRevert(abi.encodeWithSelector(UTTchainGenesisFactory.ZeroReviewer.selector, uint256(3)));
        _newFactory(
            invalid,
            keccak256(type(RegistrationRootRegistry).creationCode),
            keccak256(type(MigrationVault).creationCode),
            keccak256(type(RetirementSink).creationCode),
            keccak256(type(CanonicalUTTT).creationCode)
        );
    }

    function test_constructorRejectsDuplicateReviewer() public {
        address[5] memory invalid = reviewers;
        invalid[4] = invalid[1];
        vm.expectRevert(abi.encodeWithSelector(UTTchainGenesisFactory.DuplicateReviewer.selector, invalid[1]));
        _newFactory(
            invalid,
            keccak256(type(RegistrationRootRegistry).creationCode),
            keccak256(type(MigrationVault).creationCode),
            keccak256(type(RetirementSink).creationCode),
            keccak256(type(CanonicalUTTT).creationCode)
        );
    }

    function test_componentSaltsMatchFrozenFormula() public view {
        assertEq(
            factory.componentSalt(factory.REGISTRY_COMPONENT_TAG()),
            _salt(factory.REGISTRY_COMPONENT_TAG())
        );
        assertEq(factory.componentSalt(factory.VAULT_COMPONENT_TAG()), _salt(factory.VAULT_COMPONENT_TAG()));
        assertEq(factory.componentSalt(factory.SINK_COMPONENT_TAG()), _salt(factory.SINK_COMPONENT_TAG()));
        assertEq(factory.componentSalt(factory.TOKEN_COMPONENT_TAG()), _salt(factory.TOKEN_COMPONENT_TAG()));
    }

    function test_predictAllMatchesIndependentCreate2Formula() public view {
        (
            bytes memory registryCode,
            bytes memory vaultCode,
            bytes memory sinkCode,
            bytes memory tokenCode
        ) = _codes();

        UTTchainGenesisFactory.GenesisAddresses memory predicted =
            factory.predictAll(registryCode, vaultCode, sinkCode, tokenCode);

        bytes memory registryInit = bytes.concat(registryCode, abi.encode(MIGRATION_ID, reviewers));
        address registryExpected = _compute(
            address(factory),
            _salt(factory.REGISTRY_COMPONENT_TAG()),
            keccak256(registryInit)
        );

        bytes memory vaultInit = bytes.concat(
            vaultCode,
            abi.encode(MIGRATION_ID, ECONOMIC_ROOT, registryExpected, GENESIS_AMOUNT, address(factory))
        );
        address vaultExpected = _compute(
            address(factory),
            _salt(factory.VAULT_COMPONENT_TAG()),
            keccak256(vaultInit)
        );

        address sinkExpected = _compute(
            address(factory),
            _salt(factory.SINK_COMPONENT_TAG()),
            keccak256(sinkCode)
        );

        bytes memory tokenInit = bytes.concat(tokenCode, abi.encode(vaultExpected));
        address tokenExpected = _compute(
            address(factory),
            _salt(factory.TOKEN_COMPONENT_TAG()),
            keccak256(tokenInit)
        );

        assertEq(predicted.registry, registryExpected);
        assertEq(predicted.vault, vaultExpected);
        assertEq(predicted.sink, sinkExpected);
        assertEq(predicted.token, tokenExpected);
    }

    function test_predictionRejectsCreationCodeHashMismatch() public {
        (, bytes memory vaultCode, bytes memory sinkCode, bytes memory tokenCode) = _codes();
        bytes memory wrongRegistryCode = hex"00";
        bytes32 actual = keccak256(wrongRegistryCode);
        vm.expectRevert(
            abi.encodeWithSelector(
                UTTchainGenesisFactory.CreationCodeHashMismatch.selector,
                uint256(0),
                factory.registryCreationCodeHash(),
                actual
            )
        );
        // Expected-revert path: successful return is intentionally unreachable.
        // forge-lint: disable-next-line(unused-return)
        factory.predictAll(wrongRegistryCode, vaultCode, sinkCode, tokenCode);
    }

    function test_deployAllUsesPredictedAddresses() public {
        (
            bytes memory registryCode,
            bytes memory vaultCode,
            bytes memory sinkCode,
            bytes memory tokenCode
        ) = _codes();
        UTTchainGenesisFactory.GenesisAddresses memory predicted =
            factory.predictAll(registryCode, vaultCode, sinkCode, tokenCode);
        UTTchainGenesisFactory.GenesisAddresses memory deployedAddresses =
            factory.deployAll(registryCode, vaultCode, sinkCode, tokenCode);

        assertEq(deployedAddresses.registry, predicted.registry);
        assertEq(deployedAddresses.vault, predicted.vault);
        assertEq(deployedAddresses.sink, predicted.sink);
        assertEq(deployedAddresses.token, predicted.token);
        assertGt(deployedAddresses.registry.code.length, 0);
        assertGt(deployedAddresses.vault.code.length, 0);
        assertGt(deployedAddresses.sink.code.length, 0);
        assertGt(deployedAddresses.token.code.length, 0);
    }

    function test_deployAllBindsCanonicalTokenAndSupply() public {
        UTTchainGenesisFactory.GenesisAddresses memory addresses = _deploy();
        MigrationVault vault = MigrationVault(addresses.vault);
        CanonicalUTTT token = CanonicalUTTT(addresses.token);

        assertEq(vault.canonicalToken(), addresses.token);
        assertEq(token.totalSupply(), GENESIS_AMOUNT);
        assertEq(token.balanceOf(addresses.vault), GENESIS_AMOUNT);
        assertEq(token.decimals(), 6);
        assertEq(token.name(), "Unified Trading Terminal Token");
        assertEq(token.symbol(), "UTTT");
    }

    function test_deployAllBindsRegistryVaultAndReviewers() public {
        UTTchainGenesisFactory.GenesisAddresses memory addresses = _deploy();
        RegistrationRootRegistry registry = RegistrationRootRegistry(addresses.registry);
        MigrationVault vault = MigrationVault(addresses.vault);
        address[5] memory observed = registry.reviewers();

        assertEq(registry.migrationId(), MIGRATION_ID);
        assertEq(observed[0], reviewers[0]);
        assertEq(observed[1], reviewers[1]);
        assertEq(observed[2], reviewers[2]);
        assertEq(observed[3], reviewers[3]);
        assertEq(observed[4], reviewers[4]);
        assertEq(vault.migrationId(), MIGRATION_ID);
        assertEq(vault.economicRoot(), ECONOMIC_ROOT);
        assertEq(address(vault.registrationRegistry()), addresses.registry);
        assertEq(vault.factory(), address(factory));
        assertEq(vault.canonicalGenesisAmount(), GENESIS_AMOUNT);
    }

    function test_deployAllStoresFinalAddressesAndIsOneShot() public {
        UTTchainGenesisFactory.GenesisAddresses memory addresses = _deploy();
        assertTrue(factory.deployed());
        assertEq(factory.registrationRootRegistry(), addresses.registry);
        assertEq(factory.migrationVault(), addresses.vault);
        assertEq(factory.retirementSink(), addresses.sink);
        assertEq(factory.canonicalToken(), addresses.token);

        (bytes memory registryCode, bytes memory vaultCode, bytes memory sinkCode, bytes memory tokenCode) = _codes();
        vm.expectRevert(UTTchainGenesisFactory.GenesisAlreadyDeployed.selector);
        // Expected-revert path: successful return is intentionally unreachable.
        // forge-lint: disable-next-line(unused-return)
        factory.deployAll(registryCode, vaultCode, sinkCode, tokenCode);
    }

    function test_wrongChainDeployAllDoesNotConsumeOneShot() public {
        (bytes memory registryCode, bytes memory vaultCode, bytes memory sinkCode, bytes memory tokenCode) = _codes();
        vm.chainId(1);
        vm.expectRevert(abi.encodeWithSelector(UTTchainGenesisFactory.WrongChain.selector, uint256(1)));
        // Expected-revert path: successful return is intentionally unreachable.
        // forge-lint: disable-next-line(unused-return)
        factory.deployAll(registryCode, vaultCode, sinkCode, tokenCode);
        assertFalse(factory.deployed());

        vm.chainId(RH_CHAIN_ID);
        UTTchainGenesisFactory.GenesisAddresses memory addresses =
            factory.deployAll(registryCode, vaultCode, sinkCode, tokenCode);
        assertTrue(factory.deployed());
        assertGt(addresses.token.code.length, 0);
    }

    function test_atomicRollbackIfFinalTokenDeploymentFails() public {
        bytes memory badTokenCode = type(RevertingGenesisComponent).creationCode;
        UTTchainGenesisFactory badFactory = _newFactory(
            reviewers,
            keccak256(type(RegistrationRootRegistry).creationCode),
            keccak256(type(MigrationVault).creationCode),
            keccak256(type(RetirementSink).creationCode),
            keccak256(badTokenCode)
        );

        bytes memory registryCode = type(RegistrationRootRegistry).creationCode;
        bytes memory vaultCode = type(MigrationVault).creationCode;
        bytes memory sinkCode = type(RetirementSink).creationCode;

        UTTchainGenesisFactory.GenesisAddresses memory predicted =
            badFactory.predictAll(registryCode, vaultCode, sinkCode, badTokenCode);

        vm.expectRevert(
            abi.encodeWithSelector(
                UTTchainGenesisFactory.ComponentDeploymentFailed.selector,
                badFactory.TOKEN_COMPONENT_TAG()
            )
        );
        // Expected-revert path: successful return is intentionally unreachable.
        // forge-lint: disable-next-line(unused-return)
        badFactory.deployAll(registryCode, vaultCode, sinkCode, badTokenCode);

        assertFalse(badFactory.deployed());
        assertEq(predicted.registry.code.length, 0);
        assertEq(predicted.vault.code.length, 0);
        assertEq(predicted.sink.code.length, 0);
        assertEq(predicted.token.code.length, 0);
    }

    function test_retirementSinkCompositionRemainsZeroAuthority() public {
        UTTchainGenesisFactory.GenesisAddresses memory addresses = _deploy();
        assertGt(addresses.sink.code.length, 0);
        (bool success,) = addresses.sink.call(hex"deadbeef");
        assertFalse(success);
    }

    function testFuzz_componentSaltIsDomainSeparated(bytes32 tag) public view {
        vm.assume(tag != factory.REGISTRY_COMPONENT_TAG());
        bytes32 arbitrarySalt = factory.componentSalt(tag);
        assertEq(arbitrarySalt, _salt(tag));
        assertTrue(arbitrarySalt != factory.componentSalt(factory.REGISTRY_COMPONENT_TAG()));
    }

    function _deploy() internal returns (UTTchainGenesisFactory.GenesisAddresses memory) {
        (bytes memory registryCode, bytes memory vaultCode, bytes memory sinkCode, bytes memory tokenCode) = _codes();
        return factory.deployAll(registryCode, vaultCode, sinkCode, tokenCode);
    }

    function _newFactory(
        address[5] memory reviewers_,
        bytes32 registryHash,
        bytes32 vaultHash,
        bytes32 sinkHash,
        bytes32 tokenHash
    ) internal returns (UTTchainGenesisFactory) {
        return new UTTchainGenesisFactory(
            MIGRATION_ID,
            ECONOMIC_ROOT,
            MANIFEST_HASH,
            reviewers_,
            registryHash,
            vaultHash,
            sinkHash,
            tokenHash
        );
    }

    function _codes()
        internal
        pure
        returns (
            bytes memory registryCode,
            bytes memory vaultCode,
            bytes memory sinkCode,
            bytes memory tokenCode
        )
    {
        registryCode = type(RegistrationRootRegistry).creationCode;
        vaultCode = type(MigrationVault).creationCode;
        sinkCode = type(RetirementSink).creationCode;
        tokenCode = type(CanonicalUTTT).creationCode;
    }

    function _reviewers() internal pure returns (address[5] memory values) {
        values[0] = address(0x1001);
        values[1] = address(0x1002);
        values[2] = address(0x1003);
        values[3] = address(0x1004);
        values[4] = address(0x1005);
    }

    function _salt(bytes32 componentTag) internal pure returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("UTTCHAIN_UTTT_DEPLOYMENT_V1"),
                RH_CHAIN_ID,
                MIGRATION_ID,
                componentTag,
                MANIFEST_HASH
            )
        );
    }

    function _compute(address deployer, bytes32 salt, bytes32 initCodeHash)
        internal
        pure
        returns (address result)
    {
        bytes32 digest = keccak256(
            abi.encodePacked(bytes1(0xff), deployer, salt, initCodeHash)
        );
        assembly ("memory-safe") {
            result := and(digest, 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }
}
