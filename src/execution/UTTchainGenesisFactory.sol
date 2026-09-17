// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

interface IMigrationVaultGenesis {
    function bindCanonicalToken(address token) external;
    function canonicalToken() external view returns (address);
}

/// @title UTTchainGenesisFactory
/// @notice One-shot deterministic factory for the canonical UTTT genesis stack.
/// @dev Component creation code is supplied at execution but must match immutable constructor-bound hashes.
contract UTTchainGenesisFactory {
    uint256 public constant ROBINHOOD_CHAIN_ID = 4663;
    uint64 public constant CANONICAL_GENESIS_AMOUNT = 999_997_438_658_454;

    bytes32 public constant DEPLOYMENT_DOMAIN = keccak256("UTTCHAIN_UTTT_DEPLOYMENT_V1");
    bytes32 public constant REGISTRY_COMPONENT_TAG = keccak256("RegistrationRootRegistry");
    bytes32 public constant VAULT_COMPONENT_TAG = keccak256("MigrationVault");
    bytes32 public constant SINK_COMPONENT_TAG = keccak256("RetirementSink");
    bytes32 public constant TOKEN_COMPONENT_TAG = keccak256("CanonicalUTTT");

    error WrongChain(uint256 actualChainId);
    error ZeroMigrationId();
    error ZeroEconomicRoot();
    error ZeroDeploymentManifestHash();
    error ZeroCreationCodeHash(uint256 componentIndex);
    error ZeroReviewer(uint256 index);
    error DuplicateReviewer(address reviewer);
    error GenesisAlreadyDeployed();
    error CreationCodeHashMismatch(uint256 componentIndex, bytes32 expected, bytes32 actual);
    error ComponentDeploymentFailed(bytes32 componentTag);
    error ComponentAddressMismatch(bytes32 componentTag, address expected, address actual);
    error CanonicalTokenBindingMismatch(address expected, address actual);

    event GenesisDeployed(
        address indexed registrationRootRegistry,
        address indexed migrationVault,
        address indexed canonicalToken,
        address retirementSink,
        bytes32 deploymentManifestHash
    );

    struct GenesisAddresses {
        address registry;
        address vault;
        address sink;
        address token;
    }

    bytes32 public immutable migrationId;
    bytes32 public immutable economicRoot;
    bytes32 public immutable deploymentManifestHash;
    bytes32 public immutable registryCreationCodeHash;
    bytes32 public immutable vaultCreationCodeHash;
    bytes32 public immutable sinkCreationCodeHash;
    bytes32 public immutable tokenCreationCodeHash;

    address[5] private _initialReviewers;

    bool public deployed;
    address public registrationRootRegistry;
    address public migrationVault;
    address public retirementSink;
    address public canonicalToken;

    constructor(
        bytes32 migrationId_,
        bytes32 economicRoot_,
        bytes32 deploymentManifestHash_,
        address[5] memory initialReviewers_,
        bytes32 registryCreationCodeHash_,
        bytes32 vaultCreationCodeHash_,
        bytes32 sinkCreationCodeHash_,
        bytes32 tokenCreationCodeHash_
    ) {
        if (block.chainid != ROBINHOOD_CHAIN_ID) revert WrongChain(block.chainid);
        if (migrationId_ == bytes32(0)) revert ZeroMigrationId();
        if (economicRoot_ == bytes32(0)) revert ZeroEconomicRoot();
        if (deploymentManifestHash_ == bytes32(0)) revert ZeroDeploymentManifestHash();
        if (registryCreationCodeHash_ == bytes32(0)) revert ZeroCreationCodeHash(0);
        if (vaultCreationCodeHash_ == bytes32(0)) revert ZeroCreationCodeHash(1);
        if (sinkCreationCodeHash_ == bytes32(0)) revert ZeroCreationCodeHash(2);
        if (tokenCreationCodeHash_ == bytes32(0)) revert ZeroCreationCodeHash(3);

        _validateReviewerSet(initialReviewers_);

        migrationId = migrationId_;
        economicRoot = economicRoot_;
        deploymentManifestHash = deploymentManifestHash_;
        registryCreationCodeHash = registryCreationCodeHash_;
        vaultCreationCodeHash = vaultCreationCodeHash_;
        sinkCreationCodeHash = sinkCreationCodeHash_;
        tokenCreationCodeHash = tokenCreationCodeHash_;

        _initialReviewers[0] = initialReviewers_[0];
        _initialReviewers[1] = initialReviewers_[1];
        _initialReviewers[2] = initialReviewers_[2];
        _initialReviewers[3] = initialReviewers_[3];
        _initialReviewers[4] = initialReviewers_[4];
    }

    function initialReviewers() external view returns (address[5] memory) {
        return _reviewersMemory();
    }

    function componentSalt(bytes32 componentTag) public view returns (bytes32) {
        return keccak256(
            abi.encode(
                DEPLOYMENT_DOMAIN,
                ROBINHOOD_CHAIN_ID,
                migrationId,
                componentTag,
                deploymentManifestHash
            )
        );
    }

    function predictAll(
        bytes calldata registryCreationCode,
        bytes calldata vaultCreationCode,
        bytes calldata sinkCreationCode,
        bytes calldata tokenCreationCode
    ) external view returns (GenesisAddresses memory predicted) {
        _validateCreationCodeHashes(
            registryCreationCode,
            vaultCreationCode,
            sinkCreationCode,
            tokenCreationCode
        );
        return _predictAll(
            registryCreationCode,
            vaultCreationCode,
            sinkCreationCode,
            tokenCreationCode
        );
    }

    function deployAll(
        bytes calldata registryCreationCode,
        bytes calldata vaultCreationCode,
        bytes calldata sinkCreationCode,
        bytes calldata tokenCreationCode
    ) external returns (GenesisAddresses memory addresses) {
        if (block.chainid != ROBINHOOD_CHAIN_ID) revert WrongChain(block.chainid);
        if (deployed) revert GenesisAlreadyDeployed();

        _validateCreationCodeHashes(
            registryCreationCode,
            vaultCreationCode,
            sinkCreationCode,
            tokenCreationCode
        );

        GenesisAddresses memory predicted = _predictAll(
            registryCreationCode,
            vaultCreationCode,
            sinkCreationCode,
            tokenCreationCode
        );

        deployed = true;

        // The predicted addresses are already fully bound to the validated
        // creation code and constructor arguments. Emitting here keeps the
        // durable success event before any CREATE2/external interaction.
        // Any downstream failure reverts this log with the whole transaction.
        // The event is emitted before every CREATE2/external interaction and
        // `deployed` is already true, so recursive deployAll cannot fabricate
        // a second durable genesis log. Any downstream failure reverts this
        // event with the entire transaction.
        // forge-lint: disable-next-item(reentrancy-events)
        emit GenesisDeployed(
            predicted.registry,
            predicted.vault,
            predicted.token,
            predicted.sink,
            deploymentManifestHash
        );

        addresses.registry = _deployRegistry(registryCreationCode);
        _requireAddress(REGISTRY_COMPONENT_TAG, predicted.registry, addresses.registry);

        addresses.vault = _deployVault(vaultCreationCode, addresses.registry);
        _requireAddress(VAULT_COMPONENT_TAG, predicted.vault, addresses.vault);

        addresses.sink = _deploy(
            componentSalt(SINK_COMPONENT_TAG),
            _sinkInitCode(sinkCreationCode),
            SINK_COMPONENT_TAG
        );
        _requireAddress(SINK_COMPONENT_TAG, predicted.sink, addresses.sink);

        addresses.token = _deployToken(tokenCreationCode, addresses.vault);
        _requireAddress(TOKEN_COMPONENT_TAG, predicted.token, addresses.token);

        IMigrationVaultGenesis(addresses.vault).bindCanonicalToken(addresses.token);
        address boundToken = IMigrationVaultGenesis(addresses.vault).canonicalToken();
        if (boundToken != addresses.token) {
            revert CanonicalTokenBindingMismatch(addresses.token, boundToken);
        }

        registrationRootRegistry = addresses.registry;
        migrationVault = addresses.vault;
        retirementSink = addresses.sink;
        canonicalToken = addresses.token;
    }

    function _predictAll(
        bytes calldata registryCreationCode,
        bytes calldata vaultCreationCode,
        bytes calldata sinkCreationCode,
        bytes calldata tokenCreationCode
    ) private view returns (GenesisAddresses memory predicted) {
        bytes memory registryInitCode = _registryInitCode(registryCreationCode);
        predicted.registry = _computeCreate2Address(
            componentSalt(REGISTRY_COMPONENT_TAG),
            keccak256(registryInitCode)
        );

        bytes memory vaultInitCode = _vaultInitCode(vaultCreationCode, predicted.registry);
        predicted.vault = _computeCreate2Address(
            componentSalt(VAULT_COMPONENT_TAG),
            keccak256(vaultInitCode)
        );

        predicted.sink = _computeCreate2Address(
            componentSalt(SINK_COMPONENT_TAG),
            keccak256(_sinkInitCode(sinkCreationCode))
        );

        bytes memory tokenInitCode = _tokenInitCode(tokenCreationCode, predicted.vault);
        predicted.token = _computeCreate2Address(
            componentSalt(TOKEN_COMPONENT_TAG),
            keccak256(tokenInitCode)
        );
    }

    function _deployRegistry(bytes calldata registryCreationCode) private returns (address) {
        return _deploy(
            componentSalt(REGISTRY_COMPONENT_TAG),
            _registryInitCode(registryCreationCode),
            REGISTRY_COMPONENT_TAG
        );
    }

    function _deployVault(bytes calldata vaultCreationCode, address registry)
        private
        returns (address)
    {
        return _deploy(
            componentSalt(VAULT_COMPONENT_TAG),
            _vaultInitCode(vaultCreationCode, registry),
            VAULT_COMPONENT_TAG
        );
    }

    function _deployToken(bytes calldata tokenCreationCode, address vault)
        private
        returns (address)
    {
        return _deploy(
            componentSalt(TOKEN_COMPONENT_TAG),
            _tokenInitCode(tokenCreationCode, vault),
            TOKEN_COMPONENT_TAG
        );
    }

    function _registryInitCode(bytes calldata registryCreationCode)
        private
        view
        returns (bytes memory)
    {
        return bytes.concat(
            registryCreationCode,
            abi.encode(migrationId, _reviewersMemory())
        );
    }

    function _vaultInitCode(bytes calldata vaultCreationCode, address registry)
        private
        view
        returns (bytes memory)
    {
        return bytes.concat(
            vaultCreationCode,
            abi.encode(
                migrationId,
                economicRoot,
                registry,
                CANONICAL_GENESIS_AMOUNT,
                address(this)
            )
        );
    }

    function _tokenInitCode(bytes calldata tokenCreationCode, address vault)
        private
        pure
        returns (bytes memory)
    {
        return bytes.concat(tokenCreationCode, abi.encode(vault));
    }

    function _sinkInitCode(bytes calldata sinkCreationCode)
        private
        pure
        returns (bytes memory)
    {
        return sinkCreationCode;
    }

    function _validateCreationCodeHashes(
        bytes calldata registryCreationCode,
        bytes calldata vaultCreationCode,
        bytes calldata sinkCreationCode,
        bytes calldata tokenCreationCode
    ) private view {
        _requireCreationCodeHash(0, registryCreationCodeHash, keccak256(registryCreationCode));
        _requireCreationCodeHash(1, vaultCreationCodeHash, keccak256(vaultCreationCode));
        _requireCreationCodeHash(2, sinkCreationCodeHash, keccak256(sinkCreationCode));
        _requireCreationCodeHash(3, tokenCreationCodeHash, keccak256(tokenCreationCode));
    }

    function _requireCreationCodeHash(uint256 index, bytes32 expected, bytes32 actual) private pure {
        if (actual != expected) revert CreationCodeHashMismatch(index, expected, actual);
    }

    function _deploy(bytes32 salt, bytes memory initCode, bytes32 componentTag)
        private
        returns (address deployedAddress)
    {
        assembly ("memory-safe") {
            deployedAddress := create2(0, add(initCode, 0x20), mload(initCode), salt)
        }
        if (deployedAddress == address(0)) revert ComponentDeploymentFailed(componentTag);
    }

    function _requireAddress(bytes32 componentTag, address expected, address actual) private pure {
        if (actual != expected) revert ComponentAddressMismatch(componentTag, expected, actual);
    }

    function _computeCreate2Address(bytes32 salt, bytes32 initCodeHash)
        private
        view
        returns (address result)
    {
        bytes32 digest = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, initCodeHash)
        );
        assembly ("memory-safe") {
            result := and(digest, 0xffffffffffffffffffffffffffffffffffffffff)
        }
    }

    function _reviewersMemory() private view returns (address[5] memory reviewers_) {
        reviewers_[0] = _initialReviewers[0];
        reviewers_[1] = _initialReviewers[1];
        reviewers_[2] = _initialReviewers[2];
        reviewers_[3] = _initialReviewers[3];
        reviewers_[4] = _initialReviewers[4];
    }

    function _validateReviewerSet(address[5] memory reviewers_) private pure {
        if (reviewers_[0] == address(0)) revert ZeroReviewer(0);
        if (reviewers_[1] == address(0)) revert ZeroReviewer(1);
        if (reviewers_[2] == address(0)) revert ZeroReviewer(2);
        if (reviewers_[3] == address(0)) revert ZeroReviewer(3);
        if (reviewers_[4] == address(0)) revert ZeroReviewer(4);

        if (
            reviewers_[0] == reviewers_[1] ||
            reviewers_[0] == reviewers_[2] ||
            reviewers_[0] == reviewers_[3] ||
            reviewers_[0] == reviewers_[4]
        ) revert DuplicateReviewer(reviewers_[0]);
        if (
            reviewers_[1] == reviewers_[2] ||
            reviewers_[1] == reviewers_[3] ||
            reviewers_[1] == reviewers_[4]
        ) revert DuplicateReviewer(reviewers_[1]);
        if (
            reviewers_[2] == reviewers_[3] ||
            reviewers_[2] == reviewers_[4]
        ) revert DuplicateReviewer(reviewers_[2]);
        if (reviewers_[3] == reviewers_[4]) revert DuplicateReviewer(reviewers_[3]);
    }
}
