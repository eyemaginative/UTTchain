// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Test} from "forge-std/Test.sol";
import {RegistrationRootRegistry} from "../../src/registry/RegistrationRootRegistry.sol";
import {IERC1271} from "@openzeppelin/contracts/interfaces/IERC1271.sol";

contract MockERC1271Reviewer is IERC1271 {
    bytes32 internal approvedDigest;
    bytes32 internal approvedSignatureHash;

    function approve(bytes32 digest, bytes calldata signature) external {
        approvedDigest = digest;
        approvedSignatureHash = keccak256(signature);
    }

    function isValidSignature(
        bytes32 digest,
        bytes calldata signature
    ) external view override returns (bytes4) {
        if (
            digest == approvedDigest &&
            keccak256(signature) == approvedSignatureHash
        ) {
            return IERC1271.isValidSignature.selector;
        }

        return bytes4(0xffffffff);
    }
}

abstract contract RegistrationRootRegistryTestBase is Test {

    RegistrationRootRegistry internal registry;

    bytes32 internal constant MIGRATION_ID = keccak256("UTTCHAIN_TEST_MIGRATION_ID");

    uint256[5] internal reviewerKeys;
    address[5] internal initialReviewers;


    function setUp() public {
        vm.chainId(4663);

        reviewerKeys[0] = 0xA11CE;
        reviewerKeys[1] = 0xB0B;
        reviewerKeys[2] = 0xCA11;
        reviewerKeys[3] = 0xD00D;
        reviewerKeys[4] = 0xE11E;

        for (uint256 i = 0; i < 5; ++i) {
            initialReviewers[i] = vm.addr(reviewerKeys[i]);
        }

        registry = new RegistrationRootRegistry(
            MIGRATION_ID,
            initialReviewers
        );
    }

    function _proposeFirstRoot()
        internal
        returns (RegistrationRootRegistry.RootProposal memory proposal)
    {
        proposal =
            _proposal(
                1,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        registry.proposeRoot(
            proposal,
            _signDigest(
                registry.rootProposalDigest(proposal),
                0,
                1,
                2
            )
        );
    }

    function _proposeRotation()
        internal
        returns (address[5] memory replacements)
    {
        replacements =
            _replacementReviewers();

        bytes32 digest =
            registry.reviewerRotationDigest(
                1,
                replacements
            );

        registry.proposeReviewerRotation(
            replacements,
            _signDigest(
                digest,
                0,
                1,
                2
            )
        );
    }

    function _proposal(
        uint256 nonce,
        uint256 epoch,
        bytes32 root,
        bytes32 manifestHash,
        bytes32 previousManifestHash
    )
        internal
        pure
        returns (RegistrationRootRegistry.RootProposal memory proposal)
    {
        proposal = RegistrationRootRegistry.RootProposal({
            nonce: nonce,
            registrationEpoch: epoch,
            root: root,
            datasetSha256: keccak256(
                abi.encode("DATASET", root)
            ),
            sourceEvidenceRoot: keccak256(
                abi.encode("SOURCE_EVIDENCE", root)
            ),
            manifestHash: manifestHash,
            recordCount: 101,
            previousAcceptedManifestHash: previousManifestHash
        });
    }

    function _signature(
        uint256 privateKey,
        bytes32 digest
    )
        internal
        pure
        returns (RegistrationRootRegistry.ReviewerSignature memory approval)
    {
        (uint8 v, bytes32 r, bytes32 s) =
            vm.sign(privateKey, digest);

        approval = RegistrationRootRegistry.ReviewerSignature({
            reviewer: vm.addr(privateKey),
            signature: abi.encodePacked(r, s, v)
        });
    }

    function _signDigest(
        bytes32 digest,
        uint256 first,
        uint256 second,
        uint256 third
    )
        internal
        view
        returns (RegistrationRootRegistry.ReviewerSignature[] memory approvals)
    {
        approvals =
            new RegistrationRootRegistry.ReviewerSignature[](3);

        approvals[0] =
            _signature(reviewerKeys[first], digest);
        approvals[1] =
            _signature(reviewerKeys[second], digest);
        approvals[2] =
            _signature(reviewerKeys[third], digest);
    }

    function _signDigestWithKeys(
        bytes32 digest,
        uint256[5] memory keys,
        uint256 first,
        uint256 second,
        uint256 third
    )
        internal
        pure
        returns (RegistrationRootRegistry.ReviewerSignature[] memory approvals)
    {
        approvals =
            new RegistrationRootRegistry.ReviewerSignature[](3);

        approvals[0] =
            _signature(keys[first], digest);
        approvals[1] =
            _signature(keys[second], digest);
        approvals[2] =
            _signature(keys[third], digest);
    }

    function _replacementKeys()
        internal
        pure
        returns (uint256[5] memory keys)
    {
        keys[0] = 0x1111;
        keys[1] = 0x2222;
        keys[2] = 0x3333;
        keys[3] = 0x4444;
        keys[4] = 0x5555;
    }

    function _replacementReviewers()
        internal
        pure
        returns (address[5] memory reviewers_)
    {
        uint256[5] memory keys =
            _replacementKeys();

        for (uint256 i = 0; i < 5; ++i) {
            reviewers_[i] =
                vm.addr(keys[i]);
        }
    }
}

contract RegistrationRootRegistryCoreTest is RegistrationRootRegistryTestBase {
    function test_constructorBindsCoreConstantsAndReviewerSet() public view {
        assertEq(registry.ROBINHOOD_CHAIN_ID(), 4663);
        assertEq(registry.REVIEWER_COUNT(), 5);
        assertEq(registry.REVIEWER_THRESHOLD(), 3);
        assertEq(registry.ROOT_REVIEW_DELAY(), 14 days);
        assertEq(registry.REVIEWER_ROTATION_DELAY(), 30 days);
        assertEq(registry.migrationId(), MIGRATION_ID);

        address[5] memory observed = registry.reviewers();

        for (uint256 i = 0; i < 5; ++i) {
            assertEq(observed[i], initialReviewers[i]);
            assertTrue(registry.isReviewer(initialReviewers[i]));
        }

        assertEq(
            registry.currentReviewerSetHash(),
            keccak256(abi.encode(initialReviewers))
        );
    }

    function test_constructorRejectsWrongChain() public {
        vm.chainId(1);

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.WrongChain.selector,
                uint256(1)
            )
        );

        new RegistrationRootRegistry(
            MIGRATION_ID,
            initialReviewers
        );
    }

    function test_constructorRejectsZeroMigrationId() public {
        vm.expectRevert(
            RegistrationRootRegistry.ZeroMigrationId.selector
        );

        new RegistrationRootRegistry(
            bytes32(0),
            initialReviewers
        );
    }

    function test_constructorRejectsZeroReviewer() public {
        address[5] memory reviewers_ = initialReviewers;
        reviewers_[3] = address(0);

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.ZeroReviewer.selector,
                uint256(3)
            )
        );

        new RegistrationRootRegistry(
            MIGRATION_ID,
            reviewers_
        );
    }

    function test_constructorRejectsDuplicateReviewer() public {
        address[5] memory reviewers_ = initialReviewers;
        reviewers_[4] = reviewers_[1];

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.DuplicateReviewer.selector,
                reviewers_[1]
            )
        );

        new RegistrationRootRegistry(
            MIGRATION_ID,
            reviewers_
        );
    }

    function test_eip712DomainBindsNameVersionChainRegistryAndMigrationId() public view {
        bytes32 expected = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
                ),
                keccak256("UTTchain RegistrationRootRegistry"),
                keccak256("1"),
                uint256(4663),
                address(registry),
                MIGRATION_ID
            )
        );

        assertEq(
            registry.eip712DomainSeparator(),
            expected
        );
    }

    function test_rootProposalDigestMatchesIndependentReference() public view {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "RootProposal(uint256 nonce,uint256 registrationEpoch,bytes32 root,bytes32 datasetSha256,bytes32 sourceEvidenceRoot,bytes32 manifestHash,uint256 recordCount,bytes32 previousAcceptedManifestHash)"
                ),
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

        bytes32 expected = keccak256(
            abi.encodePacked(
                hex"1901",
                registry.eip712DomainSeparator(),
                structHash
            )
        );

        assertEq(
            registry.rootProposalDigest(proposal),
            expected
        );
    }

    function test_rootCancellationDigestBindsProposalNonceAndDigest() public view {
        bytes32 proposalDigest =
            keccak256("PROPOSAL_DIGEST");

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "RootCancellation(uint256 nonce,bytes32 proposalDigest)"
                ),
                uint256(7),
                proposalDigest
            )
        );

        bytes32 expected = keccak256(
            abi.encodePacked(
                hex"1901",
                registry.eip712DomainSeparator(),
                structHash
            )
        );

        assertEq(
            registry.rootCancellationDigest(
                7,
                proposalDigest
            ),
            expected
        );
    }

    function testFuzz_rootProposalDigestChangesWhenRootChanges(
        bytes32 rootA,
        bytes32 rootB
    ) public view {
        vm.assume(rootA != rootB);

        RegistrationRootRegistry.RootProposal memory first =
            _proposal(
                1,
                1,
                rootA,
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        RegistrationRootRegistry.RootProposal memory second =
            _proposal(
                1,
                1,
                rootB,
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        assertNotEq(
            registry.rootProposalDigest(first),
            registry.rootProposalDigest(second)
        );
    }


function test_signatureCheckerSupportsERC1271Reviewer() public {
    MockERC1271Reviewer contractReviewer =
        new MockERC1271Reviewer();

    address[5] memory reviewers_;
    reviewers_[0] = address(contractReviewer);
    reviewers_[1] = initialReviewers[0];
    reviewers_[2] = initialReviewers[1];
    reviewers_[3] = initialReviewers[2];
    reviewers_[4] = initialReviewers[3];

    RegistrationRootRegistry contractRegistry =
        new RegistrationRootRegistry(
            keccak256("ERC1271_MIGRATION_ID"),
            reviewers_
        );

    RegistrationRootRegistry.RootProposal memory proposal =
        _proposal(
            1,
            1,
            keccak256("ERC1271_ROOT"),
            keccak256("ERC1271_MANIFEST"),
            bytes32(0)
        );

    bytes32 digest =
        contractRegistry.rootProposalDigest(proposal);

    bytes memory contractSignature = hex"123456";

    contractReviewer.approve(
        digest,
        contractSignature
    );

    RegistrationRootRegistry.ReviewerSignature[] memory approvals =
        new RegistrationRootRegistry.ReviewerSignature[](3);

    approvals[0] = RegistrationRootRegistry.ReviewerSignature({
        reviewer: address(contractReviewer),
        signature: contractSignature
    });
    approvals[1] = _signature(reviewerKeys[0], digest);
    approvals[2] = _signature(reviewerKeys[1], digest);

    contractRegistry.proposeRoot(
        proposal,
        approvals
    );

    assertTrue(contractRegistry.hasPendingRoot());
}
}

contract RegistrationRootRegistryRootLifecycleTest is RegistrationRootRegistryTestBase {
    function test_anyRelayerCanProposeWithThreeUniqueReviewerApprovals() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        bytes32 digest =
            registry.rootProposalDigest(proposal);

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            _signDigest(digest, 0, 1, 2);

        vm.prank(address(0xBEEF));
        registry.proposeRoot(
            proposal,
            approvals
        );

        assertTrue(registry.hasPendingRoot());
        assertEq(registry.proposalNonce(), 1);
        assertEq(registry.registrationEpoch(), 0);
        assertEq(registry.pendingRootDigest(), digest);
        assertEq(
            registry.pendingRootActivateAfter(),
            block.timestamp + 14 days
        );
    }

    function test_rootProposalRequiresExactlyThreeApprovals() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        bytes32 digest =
            registry.rootProposalDigest(proposal);

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            new RegistrationRootRegistry.ReviewerSignature[](2);

        approvals[0] = _signature(reviewerKeys[0], digest);
        approvals[1] = _signature(reviewerKeys[1], digest);

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.InvalidApprovalCount.selector,
                uint256(2)
            )
        );

        registry.proposeRoot(
            proposal,
            approvals
        );
    }

    function test_rootProposalRejectsDuplicateReviewerApproval() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        bytes32 digest =
            registry.rootProposalDigest(proposal);

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            new RegistrationRootRegistry.ReviewerSignature[](3);

        approvals[0] = _signature(reviewerKeys[0], digest);
        approvals[1] = _signature(reviewerKeys[0], digest);
        approvals[2] = _signature(reviewerKeys[2], digest);

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.DuplicateApproval.selector,
                initialReviewers[0]
            )
        );

        registry.proposeRoot(
            proposal,
            approvals
        );
    }

    function test_rootProposalRejectsNonReviewerApproval() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        bytes32 digest =
            registry.rootProposalDigest(proposal);

        uint256 outsiderKey = 0xF00D;
        address outsider = vm.addr(outsiderKey);

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            new RegistrationRootRegistry.ReviewerSignature[](3);

        approvals[0] = _signature(reviewerKeys[0], digest);
        approvals[1] = _signature(reviewerKeys[1], digest);
        approvals[2] = _signature(outsiderKey, digest);

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.ApprovalNotReviewer.selector,
                outsider
            )
        );

        registry.proposeRoot(
            proposal,
            approvals
        );
    }

    function test_rootProposalRejectsSignatureNotMadeByClaimedReviewer() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        bytes32 digest =
            registry.rootProposalDigest(proposal);

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            _signDigest(digest, 0, 1, 2);

        RegistrationRootRegistry.ReviewerSignature memory wrong =
            _signature(0xF00D, digest);

        approvals[2] = RegistrationRootRegistry.ReviewerSignature({
            reviewer: initialReviewers[2],
            signature: wrong.signature
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.InvalidReviewerSignature.selector,
                initialReviewers[2]
            )
        );

        registry.proposeRoot(
            proposal,
            approvals
        );
    }

    function test_rootProposalRejectsWrongNonce() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                2,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            _signDigest(
                registry.rootProposalDigest(proposal),
                0,
                1,
                2
            );

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.InvalidProposalNonce.selector,
                uint256(1),
                uint256(2)
            )
        );

        registry.proposeRoot(
            proposal,
            approvals
        );
    }

    function test_rootProposalRejectsWrongRegistrationEpoch() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                2,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            _signDigest(
                registry.rootProposalDigest(proposal),
                0,
                1,
                2
            );

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.InvalidRegistrationEpoch.selector,
                uint256(1),
                uint256(2)
            )
        );

        registry.proposeRoot(
            proposal,
            approvals
        );
    }

    function test_rootProposalRejectsZeroCommitmentFields() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                1,
                bytes32(0),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            _signDigest(
                registry.rootProposalDigest(proposal),
                0,
                1,
                2
            );

        vm.expectRevert(
            RegistrationRootRegistry.ZeroRoot.selector
        );

        registry.proposeRoot(
            proposal,
            approvals
        );

        proposal = _proposal(
            1,
            1,
            keccak256("ROOT_1"),
            keccak256("MANIFEST_1"),
            bytes32(0)
        );
        proposal.datasetSha256 = bytes32(0);

        approvals =
            _signDigest(
                registry.rootProposalDigest(proposal),
                0,
                1,
                2
            );

        vm.expectRevert(
            RegistrationRootRegistry.ZeroDatasetSha256.selector
        );

        registry.proposeRoot(
            proposal,
            approvals
        );

        proposal = _proposal(
            1,
            1,
            keccak256("ROOT_1"),
            keccak256("MANIFEST_1"),
            bytes32(0)
        );
        proposal.sourceEvidenceRoot = bytes32(0);

        approvals =
            _signDigest(
                registry.rootProposalDigest(proposal),
                0,
                1,
                2
            );

        vm.expectRevert(
            RegistrationRootRegistry.ZeroSourceEvidenceRoot.selector
        );

        registry.proposeRoot(
            proposal,
            approvals
        );

        proposal = _proposal(
            1,
            1,
            keccak256("ROOT_1"),
            bytes32(0),
            bytes32(0)
        );

        approvals =
            _signDigest(
                registry.rootProposalDigest(proposal),
                0,
                1,
                2
            );

        vm.expectRevert(
            RegistrationRootRegistry.ZeroManifestHash.selector
        );

        registry.proposeRoot(
            proposal,
            approvals
        );

        proposal = _proposal(
            1,
            1,
            keccak256("ROOT_1"),
            keccak256("MANIFEST_1"),
            bytes32(0)
        );
        proposal.recordCount = 0;

        approvals =
            _signDigest(
                registry.rootProposalDigest(proposal),
                0,
                1,
                2
            );

        vm.expectRevert(
            RegistrationRootRegistry.ZeroRecordCount.selector
        );

        registry.proposeRoot(
            proposal,
            approvals
        );
    }

    function test_onlyOneRootProposalMayBePending() public {
        RegistrationRootRegistry.RootProposal memory first =
            _proposal(
                1,
                1,
                keccak256("ROOT_1"),
                keccak256("MANIFEST_1"),
                bytes32(0)
            );

        registry.proposeRoot(
            first,
            _signDigest(
                registry.rootProposalDigest(first),
                0,
                1,
                2
            )
        );

        RegistrationRootRegistry.RootProposal memory second =
            _proposal(
                2,
                1,
                keccak256("ROOT_2"),
                keccak256("MANIFEST_2"),
                bytes32(0)
            );

        RegistrationRootRegistry.ReviewerSignature[] memory secondApprovals =
            _signDigest(
                registry.rootProposalDigest(second),
                0,
                1,
                2
            );

        vm.expectRevert(
            RegistrationRootRegistry.RootProposalAlreadyPending.selector
        );

        registry.proposeRoot(
            second,
            secondApprovals
        );
    }

    function test_rootActivationCannotOccurBeforeFourteenDays() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposeFirstRoot();

        assertEq(proposal.registrationEpoch, 1);

        vm.warp(
            registry.pendingRootActivateAfter() - 1
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.RootReviewDelayActive.selector,
                registry.pendingRootActivateAfter()
            )
        );

        registry.activateRoot();
    }

    function test_rootActivationIsPermissionlessAfterFourteenDaysAndAppendOnly() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposeFirstRoot();

        uint256 activateAfter =
            registry.pendingRootActivateAfter();

        vm.warp(activateAfter);

        vm.prank(address(0xBEEF));
        registry.activateRoot();

        assertFalse(registry.hasPendingRoot());
        assertEq(registry.registrationEpoch(), 1);
        assertEq(
            registry.lastAcceptedManifestHash(),
            proposal.manifestHash
        );
        assertEq(
            registry.acceptedRootEpoch(proposal.root),
            1
        );
        assertEq(
            registry.acceptedManifestEpoch(proposal.manifestHash),
            1
        );

        (
            bytes32 root,
            bytes32 datasetSha256,
            bytes32 sourceEvidenceRoot,
            bytes32 manifestHash,
            uint256 recordCount,
            uint256 acceptedAt
        ) = registry.acceptedRoots(1);

        assertEq(root, proposal.root);
        assertEq(datasetSha256, proposal.datasetSha256);
        assertEq(sourceEvidenceRoot, proposal.sourceEvidenceRoot);
        assertEq(manifestHash, proposal.manifestHash);
        assertEq(recordCount, proposal.recordCount);
        assertEq(acceptedAt, activateAfter);
    }

    function test_cancelRootRequiresFreshQuorumAndPreservesProposalNonce() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposeFirstRoot();

        bytes32 cancellationDigest =
            registry.rootCancellationDigest(
                proposal.nonce,
                registry.pendingRootDigest()
            );

        RegistrationRootRegistry.ReviewerSignature[] memory approvals =
            _signDigest(cancellationDigest, 0, 1, 2);

        vm.prank(address(0xCAFE));
        registry.cancelRootProposal(approvals);

        assertFalse(registry.hasPendingRoot());
        assertEq(registry.proposalNonce(), 1);
        assertEq(registry.registrationEpoch(), 0);
        assertEq(registry.lastAcceptedManifestHash(), bytes32(0));
    }

    function test_cancelledProposalForcesNextProposalNonceButNotEpoch() public {
        RegistrationRootRegistry.RootProposal memory first =
            _proposeFirstRoot();

        registry.cancelRootProposal(
            _signDigest(
                registry.rootCancellationDigest(
                    first.nonce,
                    registry.pendingRootDigest()
                ),
                0,
                1,
                2
            )
        );

        RegistrationRootRegistry.RootProposal memory second =
            _proposal(
                2,
                1,
                keccak256("ROOT_2"),
                keccak256("MANIFEST_2"),
                bytes32(0)
            );

        registry.proposeRoot(
            second,
            _signDigest(
                registry.rootProposalDigest(second),
                0,
                1,
                2
            )
        );

        assertEq(registry.proposalNonce(), 2);
        assertEq(registry.registrationEpoch(), 0);
    }

    function test_secondAcceptedRootRequiresPreviousManifestAndNextEpoch() public {
        RegistrationRootRegistry.RootProposal memory first =
            _proposeFirstRoot();

        vm.warp(registry.pendingRootActivateAfter());
        registry.activateRoot();

        RegistrationRootRegistry.RootProposal memory wrongPrevious =
            _proposal(
                2,
                2,
                keccak256("ROOT_2"),
                keccak256("MANIFEST_2"),
                bytes32(0)
            );

        RegistrationRootRegistry.ReviewerSignature[] memory wrongPreviousApprovals =
            _signDigest(
                registry.rootProposalDigest(wrongPrevious),
                0,
                1,
                2
            );

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.InvalidPreviousAcceptedManifest.selector,
                first.manifestHash,
                bytes32(0)
            )
        );

        registry.proposeRoot(
            wrongPrevious,
            wrongPreviousApprovals
        );

        RegistrationRootRegistry.RootProposal memory second =
            _proposal(
                2,
                2,
                keccak256("ROOT_2"),
                keccak256("MANIFEST_2"),
                first.manifestHash
            );

        registry.proposeRoot(
            second,
            _signDigest(
                registry.rootProposalDigest(second),
                0,
                1,
                2
            )
        );

        vm.warp(registry.pendingRootActivateAfter());
        registry.activateRoot();

        assertEq(registry.registrationEpoch(), 2);
        assertEq(registry.acceptedRootEpoch(first.root), 1);
        assertEq(registry.acceptedRootEpoch(second.root), 2);
    }

    function test_acceptedRootAndManifestCannotBeReused() public {
        RegistrationRootRegistry.RootProposal memory first =
            _proposeFirstRoot();

        vm.warp(registry.pendingRootActivateAfter());
        registry.activateRoot();

        RegistrationRootRegistry.RootProposal memory duplicateRoot =
            _proposal(
                2,
                2,
                first.root,
                keccak256("MANIFEST_2"),
                first.manifestHash
            );

        RegistrationRootRegistry.ReviewerSignature[] memory duplicateApprovals =
            _signDigest(
                registry.rootProposalDigest(duplicateRoot),
                0,
                1,
                2
            );

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.RootAlreadyAccepted.selector,
                first.root
            )
        );

        registry.proposeRoot(
            duplicateRoot,
            duplicateApprovals
        );

        RegistrationRootRegistry.RootProposal memory duplicateManifest =
            _proposal(
                2,
                2,
                keccak256("ROOT_2"),
                first.manifestHash,
                first.manifestHash
            );

        duplicateApprovals =
            _signDigest(
                registry.rootProposalDigest(duplicateManifest),
                0,
                1,
                2
            );

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.ManifestAlreadyAccepted.selector,
                first.manifestHash
            )
        );

        registry.proposeRoot(
            duplicateManifest,
            duplicateApprovals
        );
    }
}

contract RegistrationRootRegistryRotationTest is RegistrationRootRegistryTestBase {
    function test_reviewerRotationProposalRequiresThreeCurrentReviewers() public {
        address[5] memory replacements =
            _replacementReviewers();

        bytes32 digest =
            registry.reviewerRotationDigest(
                1,
                replacements
            );

        vm.prank(address(0xBEEF));
        registry.proposeReviewerRotation(
            replacements,
            _signDigest(digest, 0, 1, 2)
        );

        assertTrue(
            registry.hasPendingReviewerRotation()
        );
        assertEq(
            registry.reviewerRotationNonce(),
            1
        );
        assertEq(
            registry.pendingReviewerSetHash(),
            keccak256(abi.encode(replacements))
        );
        assertEq(
            registry.pendingReviewerRotationDigest(),
            digest
        );
        assertEq(
            registry.pendingReviewerRotationActivateAfter(),
            block.timestamp + 30 days
        );
    }

    function test_reviewerRotationRejectsZeroDuplicateAndSameSets() public {
        address[5] memory replacements =
            _replacementReviewers();

        replacements[2] = address(0);

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.ZeroReviewer.selector,
                uint256(2)
            )
        );

        registry.proposeReviewerRotation(
            replacements,
            new RegistrationRootRegistry.ReviewerSignature[](0)
        );

        replacements =
            _replacementReviewers();
        replacements[4] = replacements[1];

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.DuplicateReviewer.selector,
                replacements[1]
            )
        );

        registry.proposeReviewerRotation(
            replacements,
            new RegistrationRootRegistry.ReviewerSignature[](0)
        );

        address[5] memory sameSet;
        sameSet[0] = initialReviewers[4];
        sameSet[1] = initialReviewers[3];
        sameSet[2] = initialReviewers[2];
        sameSet[3] = initialReviewers[1];
        sameSet[4] = initialReviewers[0];

        bytes32 sameDigest =
            registry.reviewerRotationDigest(
                1,
                sameSet
            );

        vm.expectRevert(
            RegistrationRootRegistry.SameReviewerSet.selector
        );

        registry.proposeReviewerRotation(
            sameSet,
            _signDigest(
                sameDigest,
                0,
                1,
                2
            )
        );
    }

    function test_rootAndReviewerRotationCannotBePendingTogether() public {
        RegistrationRootRegistry.RootProposal memory proposal =
            _proposeFirstRoot();

        address[5] memory replacements =
            _replacementReviewers();

        RegistrationRootRegistry.ReviewerSignature[] memory blockedApprovals =
            _signDigest(
                registry.reviewerRotationDigest(
                    1,
                    replacements
                ),
                0,
                1,
                2
            );

        vm.expectRevert(
            RegistrationRootRegistry.RootProposalAlreadyPending.selector
        );

        registry.proposeReviewerRotation(
            replacements,
            blockedApprovals
        );

        registry.cancelRootProposal(
            _signDigest(
                registry.rootCancellationDigest(
                    proposal.nonce,
                    registry.pendingRootDigest()
                ),
                0,
                1,
                2
            )
        );

        bytes32 rotationDigest =
            registry.reviewerRotationDigest(
                1,
                replacements
            );

        registry.proposeReviewerRotation(
            replacements,
            _signDigest(
                rotationDigest,
                0,
                1,
                2
            )
        );

        RegistrationRootRegistry.RootProposal memory nextProposal =
            _proposal(
                2,
                1,
                keccak256("ROOT_2"),
                keccak256("MANIFEST_2"),
                bytes32(0)
            );

        blockedApprovals =
            _signDigest(
                registry.rootProposalDigest(nextProposal),
                0,
                1,
                2
            );

        vm.expectRevert(
            RegistrationRootRegistry.ReviewerRotationAlreadyPending.selector
        );

        registry.proposeRoot(
            nextProposal,
            blockedApprovals
        );
    }

    function test_reviewerRotationCannotActivateBeforeThirtyDays() public {
        address[5] memory replacements =
            _proposeRotation();

        assertNotEq(
            keccak256(abi.encode(replacements)),
            registry.currentReviewerSetHash()
        );

        vm.warp(
            registry.pendingReviewerRotationActivateAfter() - 1
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.ReviewerRotationDelayActive.selector,
                registry.pendingReviewerRotationActivateAfter()
            )
        );

        registry.activateReviewerRotation();
    }

    function test_reviewerRotationActivatesPermissionlesslyAfterThirtyDays() public {
        address[5] memory replacements =
            _proposeRotation();

        bytes32 newSetHash =
            keccak256(abi.encode(replacements));

        vm.warp(
            registry.pendingReviewerRotationActivateAfter()
        );

        vm.prank(address(0xBEEF));
        registry.activateReviewerRotation();

        assertFalse(
            registry.hasPendingReviewerRotation()
        );
        assertEq(
            registry.currentReviewerSetHash(),
            newSetHash
        );

        address[5] memory observed =
            registry.reviewers();

        for (uint256 i = 0; i < 5; ++i) {
            assertFalse(
                registry.isReviewer(initialReviewers[i])
            );
            assertTrue(
                registry.isReviewer(replacements[i])
            );
            assertEq(
                observed[i],
                replacements[i]
            );
        }
    }

    function test_oldReviewersCannotAuthorizeAfterRotationAndNewReviewersCan() public {
        _proposeRotation();

        vm.warp(
            registry.pendingReviewerRotationActivateAfter()
        );
        registry.activateReviewerRotation();

        RegistrationRootRegistry.RootProposal memory proposal =
            _proposal(
                1,
                1,
                keccak256("ROOT_AFTER_ROTATION"),
                keccak256("MANIFEST_AFTER_ROTATION"),
                bytes32(0)
            );

        bytes32 digest =
            registry.rootProposalDigest(proposal);

        vm.expectRevert(
            abi.encodeWithSelector(
                RegistrationRootRegistry.ApprovalNotReviewer.selector,
                initialReviewers[0]
            )
        );

        registry.proposeRoot(
            proposal,
            _signDigest(digest, 0, 1, 2)
        );

        uint256[5] memory replacementKeys =
            _replacementKeys();

        registry.proposeRoot(
            proposal,
            _signDigestWithKeys(
                digest,
                replacementKeys,
                0,
                1,
                2
            )
        );

        assertTrue(registry.hasPendingRoot());
        assertEq(registry.proposalNonce(), 1);
    }

    function test_reviewerRotationDigestBindsCurrentAndReplacementSets() public view {
        address[5] memory replacements =
            _replacementReviewers();

        bytes32 newSetHash =
            keccak256(abi.encode(replacements));

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256(
                    "ReviewerRotation(uint256 nonce,bytes32 currentReviewerSetHash,bytes32 newReviewerSetHash)"
                ),
                uint256(1),
                registry.currentReviewerSetHash(),
                newSetHash
            )
        );

        bytes32 expected = keccak256(
            abi.encodePacked(
                hex"1901",
                registry.eip712DomainSeparator(),
                structHash
            )
        );

        assertEq(
            registry.reviewerRotationDigest(
                1,
                replacements
            ),
            expected
        );
    }
}
