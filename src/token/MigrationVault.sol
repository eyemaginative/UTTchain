// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {MerkleProof} from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

import {RegistrationRootRegistry} from "../registry/RegistrationRootRegistry.sol";
import {UTTTMigrationHashing} from "../registry/UTTTMigrationHashing.sol";

/// @title MigrationVault
/// @notice Ownerless claim vault for the fixed canonical UTTT migration inventory.
/// @dev The vault binds an immutable economic root, migration ID, registration registry,
///      fixed genesis amount, and one-time token-binding factory. Claims require both
///      economic and destination-registration Merkle proofs. The global entitlement
///      nullifier is consumed before the canonical-token transfer.
contract MigrationVault {
    using SafeERC20 for IERC20;

    uint256 public constant ROBINHOOD_CHAIN_ID = 4663;
    uint64 public constant CANONICAL_GENESIS_AMOUNT = 999_997_438_658_454;

    bytes32 public constant CANONICAL_NAME_HASH =
        keccak256("Unified Trading Terminal Token");
    bytes32 public constant CANONICAL_SYMBOL_HASH = keccak256("UTTT");
    uint8 public constant CANONICAL_DECIMALS = 6;

    error WrongChain(uint256 actualChainId);
    error ZeroMigrationId();
    error ZeroEconomicRoot();
    error ZeroRegistrationRegistry();
    error RegistrationRegistryHasNoCode(address registry);
    error RegistrationRegistryMigrationMismatch(
        bytes32 expectedMigrationId,
        bytes32 actualMigrationId
    );
    error InvalidCanonicalGenesisAmount(uint256 expected, uint256 provided);
    error ZeroFactory();
    error OnlyFactory(address caller);
    error CanonicalTokenAlreadyBound(address token);
    error ZeroCanonicalToken();
    error CanonicalTokenHasNoCode(address token);
    error CanonicalTokenNameMismatch();
    error CanonicalTokenSymbolMismatch();
    error CanonicalTokenDecimalsMismatch(uint8 expected, uint8 actual);
    error CanonicalTokenSupplyMismatch(uint256 expected, uint256 actual);
    error CanonicalTokenVaultBalanceMismatch(uint256 expected, uint256 actual);
    error CanonicalTokenNotBound();
    error DestinationCallerMismatch(address destination, address caller);
    error RegistrationRootNotAccepted(
        bytes32 registrationRoot,
        uint256 requestedEpoch,
        uint256 acceptedEpoch
    );
    error EntitlementAlreadyClaimed(bytes32 entitlementId, bytes32 nullifier);
    error InvalidEconomicProof();
    error InvalidRegistrationProof();
    error ClaimedUnitsExceedGenesis(uint256 attempted, uint256 maximum);


    struct ClaimRequest {
        bytes32 entitlementId;
        uint64 amountUnits;
        uint256 registrationEpoch;
        bytes32 registrationRoot;
        address destination;
        bytes32 sourceControlProofHash;
    }

    event CanonicalTokenBound(address indexed token);
    event EntitlementClaimed(
        bytes32 indexed entitlementId,
        bytes32 indexed nullifier,
        address indexed destination,
        uint64 amountUnits,
        uint256 registrationEpoch,
        bytes32 registrationRoot
    );

    bytes32 public immutable migrationId;
    bytes32 public immutable economicRoot;
    RegistrationRootRegistry public immutable registrationRegistry;
    uint64 public immutable canonicalGenesisAmount;
    address public immutable factory;

    address public canonicalToken;
    uint256 public claimedUnits;
    mapping(bytes32 nullifier => bool consumed) public consumedNullifiers;

    constructor(
        bytes32 migrationId_,
        bytes32 economicRoot_,
        RegistrationRootRegistry registrationRegistry_,
        uint64 canonicalGenesisAmount_,
        address factory_
    ) {
        if (block.chainid != ROBINHOOD_CHAIN_ID) {
            revert WrongChain(block.chainid);
        }
        if (migrationId_ == bytes32(0)) revert ZeroMigrationId();
        if (economicRoot_ == bytes32(0)) revert ZeroEconomicRoot();

        address registryAddress = address(registrationRegistry_);
        if (registryAddress == address(0)) revert ZeroRegistrationRegistry();
        if (registryAddress.code.length == 0) {
            revert RegistrationRegistryHasNoCode(registryAddress);
        }

        bytes32 registryMigrationId = registrationRegistry_.migrationId();
        if (registryMigrationId != migrationId_) {
            revert RegistrationRegistryMigrationMismatch(
                migrationId_,
                registryMigrationId
            );
        }

        if (canonicalGenesisAmount_ != CANONICAL_GENESIS_AMOUNT) {
            revert InvalidCanonicalGenesisAmount(
                CANONICAL_GENESIS_AMOUNT,
                canonicalGenesisAmount_
            );
        }

        if (factory_ == address(0)) revert ZeroFactory();

        migrationId = migrationId_;
        economicRoot = economicRoot_;
        registrationRegistry = registrationRegistry_;
        canonicalGenesisAmount = canonicalGenesisAmount_;
        factory = factory_;
    }

    /// @notice Binds the canonical token exactly once after the token has minted
    ///         the complete fixed genesis inventory directly to this vault.
    /// @dev Only the immutable genesis factory may bind. Binding verifies canonical
    ///      metadata, exact total supply, and full vault custody before claims can run.
    function bindCanonicalToken(address token) external {
        if (msg.sender != factory) revert OnlyFactory(msg.sender);

        address existingToken = canonicalToken;
        if (existingToken != address(0)) {
            revert CanonicalTokenAlreadyBound(existingToken);
        }

        if (token == address(0)) revert ZeroCanonicalToken();
        if (token.code.length == 0) revert CanonicalTokenHasNoCode(token);

        IERC20Metadata metadata = IERC20Metadata(token);

        if (keccak256(bytes(metadata.name())) != CANONICAL_NAME_HASH) {
            revert CanonicalTokenNameMismatch();
        }
        if (keccak256(bytes(metadata.symbol())) != CANONICAL_SYMBOL_HASH) {
            revert CanonicalTokenSymbolMismatch();
        }

        uint8 actualDecimals = metadata.decimals();
        if (actualDecimals != CANONICAL_DECIMALS) {
            revert CanonicalTokenDecimalsMismatch(
                CANONICAL_DECIMALS,
                actualDecimals
            );
        }

        uint256 expectedSupply = uint256(canonicalGenesisAmount);
        uint256 actualSupply = metadata.totalSupply();
        if (actualSupply != expectedSupply) {
            revert CanonicalTokenSupplyMismatch(expectedSupply, actualSupply);
        }

        uint256 vaultBalance = metadata.balanceOf(address(this));
        if (vaultBalance != expectedSupply) {
            revert CanonicalTokenVaultBalanceMismatch(
                expectedSupply,
                vaultBalance
            );
        }

        canonicalToken = token;
        emit CanonicalTokenBound(token);
    }

    /// @notice Claims one exact economic entitlement to its accepted destination.
    /// @dev Partial claims are impossible because amountUnits is committed by the
    ///      economic leaf. Registration roots must already be accepted by the
    ///      RegistrationRootRegistry. State is consumed before token transfer.
    function claim(
        bytes32 entitlementId_,
        uint64 amountUnits,
        uint256 registrationEpoch,
        bytes32 registrationRoot,
        address destination,
        bytes32 sourceControlProofHash,
        bytes32[] calldata economicProof,
        bytes32[] calldata registrationProof
    ) external {
        ClaimRequest memory request;
        request.entitlementId = entitlementId_;
        request.amountUnits = amountUnits;
        request.registrationEpoch = registrationEpoch;
        request.registrationRoot = registrationRoot;
        request.destination = destination;
        request.sourceControlProofHash = sourceControlProofHash;

        _claim(request, economicProof, registrationProof);
    }

    function _claim(
        ClaimRequest memory request,
        bytes32[] calldata economicProof,
        bytes32[] calldata registrationProof
    ) internal {
        address token = canonicalToken;
        if (token == address(0)) revert CanonicalTokenNotBound();

        if (msg.sender != request.destination) {
            revert DestinationCallerMismatch(request.destination, msg.sender);
        }

        uint256 acceptedEpoch = registrationRegistry.acceptedRootEpoch(
            request.registrationRoot
        );
        if (
            acceptedEpoch == 0 ||
            acceptedEpoch != request.registrationEpoch
        ) {
            revert RegistrationRootNotAccepted(
                request.registrationRoot,
                request.registrationEpoch,
                acceptedEpoch
            );
        }

        bytes32 nullifier = UTTTMigrationHashing.nullifier(
            migrationId,
            request.entitlementId
        );

        if (consumedNullifiers[nullifier]) {
            revert EntitlementAlreadyClaimed(request.entitlementId, nullifier);
        }

        _verifyEconomicProof(request, economicProof);
        _verifyRegistrationProof(request, registrationProof);

        uint256 nextClaimedUnits =
            claimedUnits + uint256(request.amountUnits);
        uint256 maximum = uint256(canonicalGenesisAmount);
        if (nextClaimedUnits > maximum) {
            revert ClaimedUnitsExceedGenesis(nextClaimedUnits, maximum);
        }

        consumedNullifiers[nullifier] = true;
        claimedUnits = nextClaimedUnits;

        IERC20(token).safeTransfer(
            request.destination,
            uint256(request.amountUnits)
        );

        emit EntitlementClaimed(
            request.entitlementId,
            nullifier,
            request.destination,
            request.amountUnits,
            request.registrationEpoch,
            request.registrationRoot
        );
    }

    function _verifyEconomicProof(
        ClaimRequest memory request,
        bytes32[] calldata economicProof
    ) internal view {
        bytes32 entitlementLeaf = UTTTMigrationHashing.economicLeaf(
            migrationId,
            request.entitlementId,
            request.amountUnits
        );

        if (
            !MerkleProof.verifyCalldata(
                economicProof,
                economicRoot,
                entitlementLeaf
            )
        ) {
            revert InvalidEconomicProof();
        }
    }

    function _verifyRegistrationProof(
        ClaimRequest memory request,
        bytes32[] calldata registrationProof
    ) internal view {
        bytes32 destinationLeaf = UTTTMigrationHashing.registrationLeaf(
            migrationId,
            request.entitlementId,
            request.destination,
            request.sourceControlProofHash,
            request.registrationEpoch
        );

        if (
            !MerkleProof.verifyCalldata(
                registrationProof,
                request.registrationRoot,
                destinationLeaf
            )
        ) {
            revert InvalidRegistrationProof();
        }
    }

}
