// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {SignatureChecker} from "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

/// @title RegistrationRootRegistry
/// @notice Immutable governance registry for delayed, append-only UTTT destination-registration roots.
/// @dev Reviewer authority is permanently bounded to 3-of-5 registration-root governance. The EIP-712
///      domain uses migrationId as salt and binds this registry, chain ID 4663, and version 1.
///      Reviewer signatures support EOAs and ERC-1271 contract wallets through OpenZeppelin SignatureChecker.
contract RegistrationRootRegistry {
    uint256 public constant ROBINHOOD_CHAIN_ID = 4663;
    uint256 public constant REVIEWER_COUNT = 5;
    uint256 public constant REVIEWER_THRESHOLD = 3;
    uint256 public constant ROOT_REVIEW_DELAY = 14 days;
    uint256 public constant REVIEWER_ROTATION_DELAY = 30 days;

    bytes32 public constant EIP712_DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)");
    bytes32 public constant EIP712_NAME_HASH = keccak256("UTTchain RegistrationRootRegistry");
    bytes32 public constant EIP712_VERSION_HASH = keccak256("1");

    bytes32 public constant ROOT_PROPOSAL_TYPEHASH = keccak256(
        "RootProposal(uint256 nonce,uint256 registrationEpoch,bytes32 root,bytes32 datasetSha256,bytes32 sourceEvidenceRoot,bytes32 manifestHash,uint256 recordCount,bytes32 previousAcceptedManifestHash)"
    );
    bytes32 public constant ROOT_CANCELLATION_TYPEHASH =
        keccak256("RootCancellation(uint256 nonce,bytes32 proposalDigest)");
    bytes32 public constant REVIEWER_ROTATION_TYPEHASH = keccak256(
        "ReviewerRotation(uint256 nonce,bytes32 currentReviewerSetHash,bytes32 newReviewerSetHash)"
    );

    struct ReviewerSignature {
        address reviewer;
        bytes signature;
    }

    struct RootProposal {
        uint256 nonce;
        uint256 registrationEpoch;
        bytes32 root;
        bytes32 datasetSha256;
        bytes32 sourceEvidenceRoot;
        bytes32 manifestHash;
        uint256 recordCount;
        bytes32 previousAcceptedManifestHash;
    }

    struct AcceptedRoot {
        bytes32 root;
        bytes32 datasetSha256;
        bytes32 sourceEvidenceRoot;
        bytes32 manifestHash;
        uint256 recordCount;
        uint256 acceptedAt;
    }

    error WrongChain(uint256 actualChainId);
    error ZeroMigrationId();
    error ZeroReviewer(uint256 index);
    error DuplicateReviewer(address reviewer);
    error InvalidApprovalCount(uint256 provided);
    error ApprovalNotReviewer(address reviewer);
    error DuplicateApproval(address reviewer);
    error InvalidReviewerSignature(address reviewer);
    error RootProposalAlreadyPending();
    error ReviewerRotationAlreadyPending();
    error NoPendingRootProposal();
    error NoPendingReviewerRotation();
    error InvalidProposalNonce(uint256 expected, uint256 provided);
    error InvalidRegistrationEpoch(uint256 expected, uint256 provided);
    error InvalidPreviousAcceptedManifest(bytes32 expected, bytes32 provided);
    error ZeroRoot();
    error ZeroDatasetSha256();
    error ZeroSourceEvidenceRoot();
    error ZeroManifestHash();
    error ZeroRecordCount();
    error RootAlreadyAccepted(bytes32 root);
    error ManifestAlreadyAccepted(bytes32 manifestHash);
    error RootReviewDelayActive(uint256 activateAfter);
    error ReviewerRotationDelayActive(uint256 activateAfter);
    error SameReviewerSet();

    event RootProposed(
        uint256 indexed nonce,
        uint256 indexed registrationEpoch,
        bytes32 indexed root,
        bytes32 manifestHash,
        bytes32 proposalDigest,
        uint256 activateAfter
    );
    event RootProposalCancelled(
        uint256 indexed nonce,
        uint256 indexed registrationEpoch,
        bytes32 indexed root,
        bytes32 proposalDigest
    );
    event RootActivated(
        uint256 indexed registrationEpoch,
        bytes32 indexed root,
        bytes32 indexed manifestHash,
        uint256 recordCount,
        uint256 acceptedAt
    );
    event ReviewerRotationProposed(
        uint256 indexed nonce,
        bytes32 indexed currentReviewerSetHash,
        bytes32 indexed newReviewerSetHash,
        bytes32 rotationDigest,
        uint256 activateAfter
    );
    event ReviewerRotationActivated(
        uint256 indexed nonce,
        bytes32 indexed oldReviewerSetHash,
        bytes32 indexed newReviewerSetHash,
        uint256 activatedAt
    );

    bytes32 public immutable migrationId;

    address[5] private _reviewers;
    mapping(address reviewer => bool authorized) public isReviewer;
    bytes32 public currentReviewerSetHash;

    uint256 public proposalNonce;
    uint256 public registrationEpoch;
    bytes32 public lastAcceptedManifestHash;

    mapping(uint256 epoch => AcceptedRoot accepted) public acceptedRoots;
    mapping(bytes32 root => uint256 epoch) public acceptedRootEpoch;
    mapping(bytes32 manifestHash => uint256 epoch) public acceptedManifestEpoch;

    bool public hasPendingRoot;
    RootProposal private _pendingRoot;
    bytes32 public pendingRootDigest;
    uint256 public pendingRootProposedAt;
    uint256 public pendingRootActivateAfter;

    uint256 public reviewerRotationNonce;
    bool public hasPendingReviewerRotation;
    address[5] private _pendingReviewers;
    bytes32 public pendingReviewerSetHash;
    bytes32 public pendingReviewerRotationDigest;
    uint256 public pendingReviewerRotationProposedAt;
    uint256 public pendingReviewerRotationActivateAfter;

    constructor(bytes32 migrationId_, address[5] memory initialReviewers) {
        if (block.chainid != ROBINHOOD_CHAIN_ID) revert WrongChain(block.chainid);
        if (migrationId_ == bytes32(0)) revert ZeroMigrationId();

        _validateReviewerSet(initialReviewers);

        migrationId = migrationId_;

        for (uint256 i = 0; i < REVIEWER_COUNT; ++i) {
            address reviewer = initialReviewers[i];
            _reviewers[i] = reviewer;
            isReviewer[reviewer] = true;
        }

        currentReviewerSetHash = _reviewerSetHash(initialReviewers);
    }

    function reviewers() external view returns (address[5] memory) {
        return _reviewers;
    }

    function pendingRoot()
        external
        view
        returns (
            RootProposal memory proposal,
            bytes32 proposalDigest,
            uint256 proposedAt,
            uint256 activateAfter
        )
    {
        return (
            _pendingRoot,
            pendingRootDigest,
            pendingRootProposedAt,
            pendingRootActivateAfter
        );
    }

    function pendingReviewerRotation()
        external
        view
        returns (
            address[5] memory replacementReviewers,
            uint256 nonce,
            bytes32 replacementSetHash,
            bytes32 rotationDigest,
            uint256 proposedAt,
            uint256 activateAfter
        )
    {
        return (
            _pendingReviewers,
            reviewerRotationNonce,
            pendingReviewerSetHash,
            pendingReviewerRotationDigest,
            pendingReviewerRotationProposedAt,
            pendingReviewerRotationActivateAfter
        );
    }

    function eip712DomainSeparator() public view returns (bytes32) {
        return keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                EIP712_NAME_HASH,
                EIP712_VERSION_HASH,
                block.chainid,
                address(this),
                migrationId
            )
        );
    }

    function rootProposalDigest(RootProposal calldata proposal) external view returns (bytes32) {
        RootProposal memory proposal_ = proposal;
        return _rootProposalDigest(proposal_);
    }

    function rootCancellationDigest(
        uint256 nonce,
        bytes32 proposalDigest
    ) public view returns (bytes32) {
        bytes32 structHash =
            keccak256(abi.encode(ROOT_CANCELLATION_TYPEHASH, nonce, proposalDigest));
        return MessageHashUtils.toTypedDataHash(eip712DomainSeparator(), structHash);
    }

    function reviewerRotationDigest(
        uint256 nonce,
        address[5] calldata replacementReviewers
    ) external view returns (bytes32) {
        address[5] memory replacementReviewers_ = replacementReviewers;
        return _reviewerRotationDigest(
            nonce,
            currentReviewerSetHash,
            _reviewerSetHash(replacementReviewers_)
        );
    }

    function proposeRoot(
        RootProposal calldata proposal,
        ReviewerSignature[] calldata approvals
    ) external {
        if (hasPendingRoot) revert RootProposalAlreadyPending();
        if (hasPendingReviewerRotation) revert ReviewerRotationAlreadyPending();

        uint256 expectedNonce = proposalNonce + 1;
        if (proposal.nonce != expectedNonce) {
            revert InvalidProposalNonce(expectedNonce, proposal.nonce);
        }

        uint256 expectedEpoch = registrationEpoch + 1;
        if (proposal.registrationEpoch != expectedEpoch) {
            revert InvalidRegistrationEpoch(expectedEpoch, proposal.registrationEpoch);
        }

        if (proposal.previousAcceptedManifestHash != lastAcceptedManifestHash) {
            revert InvalidPreviousAcceptedManifest(
                lastAcceptedManifestHash,
                proposal.previousAcceptedManifestHash
            );
        }

        if (proposal.root == bytes32(0)) revert ZeroRoot();
        if (proposal.datasetSha256 == bytes32(0)) revert ZeroDatasetSha256();
        if (proposal.sourceEvidenceRoot == bytes32(0)) revert ZeroSourceEvidenceRoot();
        if (proposal.manifestHash == bytes32(0)) revert ZeroManifestHash();
        if (proposal.recordCount == 0) revert ZeroRecordCount();
        if (acceptedRootEpoch[proposal.root] != 0) revert RootAlreadyAccepted(proposal.root);
        if (acceptedManifestEpoch[proposal.manifestHash] != 0) {
            revert ManifestAlreadyAccepted(proposal.manifestHash);
        }

        RootProposal memory proposal_ = proposal;
        bytes32 digest = _rootProposalDigest(proposal_);
        _requireReviewerQuorum(digest, approvals);

        proposalNonce = proposal.nonce;
        _pendingRoot = proposal_;
        pendingRootDigest = digest;
        pendingRootProposedAt = block.timestamp;
        pendingRootActivateAfter = block.timestamp + ROOT_REVIEW_DELAY;
        hasPendingRoot = true;

        emit RootProposed(
            proposal.nonce,
            proposal.registrationEpoch,
            proposal.root,
            proposal.manifestHash,
            digest,
            pendingRootActivateAfter
        );
    }

    function cancelRootProposal(ReviewerSignature[] calldata approvals) external {
        if (!hasPendingRoot) revert NoPendingRootProposal();

        RootProposal memory proposal = _pendingRoot;
        bytes32 proposalDigest = pendingRootDigest;
        bytes32 cancellationDigest =
            rootCancellationDigest(proposal.nonce, proposalDigest);

        _requireReviewerQuorum(cancellationDigest, approvals);

        delete _pendingRoot;
        delete pendingRootDigest;
        delete pendingRootProposedAt;
        delete pendingRootActivateAfter;
        hasPendingRoot = false;

        emit RootProposalCancelled(
            proposal.nonce,
            proposal.registrationEpoch,
            proposal.root,
            proposalDigest
        );
    }

    function activateRoot() external {
        if (!hasPendingRoot) revert NoPendingRootProposal();
        if (block.timestamp < pendingRootActivateAfter) {
            revert RootReviewDelayActive(pendingRootActivateAfter);
        }

        RootProposal memory proposal = _pendingRoot;

        registrationEpoch = proposal.registrationEpoch;
        lastAcceptedManifestHash = proposal.manifestHash;

        acceptedRoots[proposal.registrationEpoch] = AcceptedRoot({
            root: proposal.root,
            datasetSha256: proposal.datasetSha256,
            sourceEvidenceRoot: proposal.sourceEvidenceRoot,
            manifestHash: proposal.manifestHash,
            recordCount: proposal.recordCount,
            acceptedAt: block.timestamp
        });

        acceptedRootEpoch[proposal.root] = proposal.registrationEpoch;
        acceptedManifestEpoch[proposal.manifestHash] = proposal.registrationEpoch;

        delete _pendingRoot;
        delete pendingRootDigest;
        delete pendingRootProposedAt;
        delete pendingRootActivateAfter;
        hasPendingRoot = false;

        emit RootActivated(
            proposal.registrationEpoch,
            proposal.root,
            proposal.manifestHash,
            proposal.recordCount,
            block.timestamp
        );
    }

    function proposeReviewerRotation(
        address[5] calldata replacementReviewers,
        ReviewerSignature[] calldata approvals
    ) external {
        if (hasPendingRoot) revert RootProposalAlreadyPending();
        if (hasPendingReviewerRotation) revert ReviewerRotationAlreadyPending();

        address[5] memory replacementReviewers_ = replacementReviewers;
        _validateReviewerSet(replacementReviewers_);

        bool sameSet = true;
        for (uint256 i = 0; i < REVIEWER_COUNT; ++i) {
            if (!isReviewer[replacementReviewers_[i]]) {
                sameSet = false;
                break;
            }
        }
        if (sameSet) revert SameReviewerSet();

        uint256 nonce = reviewerRotationNonce + 1;
        bytes32 replacementSetHash = _reviewerSetHash(replacementReviewers_);
        bytes32 digest =
            _reviewerRotationDigest(nonce, currentReviewerSetHash, replacementSetHash);

        _requireReviewerQuorum(digest, approvals);

        reviewerRotationNonce = nonce;
        for (uint256 i = 0; i < REVIEWER_COUNT; ++i) {
            _pendingReviewers[i] = replacementReviewers_[i];
        }
        pendingReviewerSetHash = replacementSetHash;
        pendingReviewerRotationDigest = digest;
        pendingReviewerRotationProposedAt = block.timestamp;
        pendingReviewerRotationActivateAfter =
            block.timestamp + REVIEWER_ROTATION_DELAY;
        hasPendingReviewerRotation = true;

        emit ReviewerRotationProposed(
            nonce,
            currentReviewerSetHash,
            replacementSetHash,
            digest,
            pendingReviewerRotationActivateAfter
        );
    }

    function activateReviewerRotation() external {
        if (!hasPendingReviewerRotation) revert NoPendingReviewerRotation();
        if (block.timestamp < pendingReviewerRotationActivateAfter) {
            revert ReviewerRotationDelayActive(
                pendingReviewerRotationActivateAfter
            );
        }

        address[5] memory oldReviewers = _reviewers;
        address[5] memory newReviewers = _pendingReviewers;
        bytes32 oldSetHash = currentReviewerSetHash;
        bytes32 newSetHash = pendingReviewerSetHash;
        uint256 nonce = reviewerRotationNonce;

        for (uint256 i = 0; i < REVIEWER_COUNT; ++i) {
            isReviewer[oldReviewers[i]] = false;
        }

        for (uint256 i = 0; i < REVIEWER_COUNT; ++i) {
            address reviewer = newReviewers[i];
            _reviewers[i] = reviewer;
            isReviewer[reviewer] = true;
        }

        currentReviewerSetHash = newSetHash;

        delete _pendingReviewers;
        delete pendingReviewerSetHash;
        delete pendingReviewerRotationDigest;
        delete pendingReviewerRotationProposedAt;
        delete pendingReviewerRotationActivateAfter;
        hasPendingReviewerRotation = false;

        emit ReviewerRotationActivated(
            nonce,
            oldSetHash,
            newSetHash,
            block.timestamp
        );
    }

    function _rootProposalDigest(
        RootProposal memory proposal
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                ROOT_PROPOSAL_TYPEHASH,
                proposal.nonce,
                proposal.registrationEpoch,
                proposal.root,
                proposal.datasetSha256,
                proposal.sourceEvidenceRoot,
                proposal.manifestHash,
                proposal.recordCount,
                proposal.previousAcceptedManifestHash
            )
        );

        return MessageHashUtils.toTypedDataHash(
            eip712DomainSeparator(),
            structHash
        );
    }

    function _reviewerRotationDigest(
        uint256 nonce,
        bytes32 currentSetHash,
        bytes32 replacementSetHash
    ) internal view returns (bytes32) {
        bytes32 structHash = keccak256(
            abi.encode(
                REVIEWER_ROTATION_TYPEHASH,
                nonce,
                currentSetHash,
                replacementSetHash
            )
        );

        return MessageHashUtils.toTypedDataHash(
            eip712DomainSeparator(),
            structHash
        );
    }

    function _requireReviewerQuorum(
        bytes32 digest,
        ReviewerSignature[] calldata approvals
    ) internal view {
        if (approvals.length != REVIEWER_THRESHOLD) {
            revert InvalidApprovalCount(approvals.length);
        }

        for (uint256 i = 0; i < REVIEWER_THRESHOLD; ++i) {
            address reviewer = approvals[i].reviewer;

            if (!isReviewer[reviewer]) revert ApprovalNotReviewer(reviewer);

            for (uint256 j = 0; j < i; ++j) {
                if (approvals[j].reviewer == reviewer) {
                    revert DuplicateApproval(reviewer);
                }
            }

            if (
                !SignatureChecker.isValidSignatureNowCalldata(
                    reviewer,
                    digest,
                    approvals[i].signature
                )
            ) {
                revert InvalidReviewerSignature(reviewer);
            }
        }
    }

    function _validateReviewerSet(address[5] memory reviewers_) internal pure {
        for (uint256 i = 0; i < REVIEWER_COUNT; ++i) {
            address reviewer = reviewers_[i];
            if (reviewer == address(0)) revert ZeroReviewer(i);

            for (uint256 j = 0; j < i; ++j) {
                if (reviewers_[j] == reviewer) {
                    revert DuplicateReviewer(reviewer);
                }
            }
        }
    }

    function _reviewerSetHash(
        address[5] memory reviewers_
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(reviewers_));
    }
}
