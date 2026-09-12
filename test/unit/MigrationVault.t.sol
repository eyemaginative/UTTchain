// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Test} from "forge-std/Test.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

import {MigrationVault} from "../../src/token/MigrationVault.sol";
import {RegistrationRootRegistry} from "../../src/registry/RegistrationRootRegistry.sol";
import {UTTTMigrationHashing} from "../../src/registry/UTTTMigrationHashing.sol";

interface IMigrationVaultState {
    function consumedNullifiers(bytes32 nullifier) external view returns (bool);
    function claimedUnits() external view returns (uint256);
}

contract MockRegistrationRootRegistry {
    bytes32 public migrationId;
    mapping(bytes32 root => uint256 epoch) public acceptedRootEpoch;

    constructor(bytes32 migrationId_) {
        migrationId = migrationId_;
    }

    function setAcceptedRoot(bytes32 root, uint256 epoch) external {
        acceptedRootEpoch[root] = epoch;
    }
}

contract MockMigrationToken is IERC20Metadata {
    string public override name;
    string public override symbol;
    uint8 public override decimals;
    uint256 public override totalSupply;

    mapping(address account => uint256 balance) public override balanceOf;
    mapping(address owner => mapping(address spender => uint256 amount))
        public override allowance;

    bool public returnFalseTransfers;
    bool public orderingCheckEnabled;
    address public orderingVault;
    bytes32 public orderingNullifier;
    uint256 public orderingClaimedUnits;

    constructor(
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        uint256 supply_,
        address initialHolder
    ) {
        name = name_;
        symbol = symbol_;
        decimals = decimals_;
        totalSupply = supply_;
        balanceOf[initialHolder] = supply_;
        emit Transfer(address(0), initialHolder, supply_);
    }

    function configureReturnFalseTransfers(bool enabled) external {
        returnFalseTransfers = enabled;
    }

    function configureOrderingCheck(
        address vault,
        bytes32 nullifier,
        uint256 expectedClaimedUnits
    ) external {
        orderingVault = vault;
        orderingNullifier = nullifier;
        orderingClaimedUnits = expectedClaimedUnits;
        orderingCheckEnabled = true;
    }

    function transfer(address to, uint256 value) external override returns (bool) {
        if (orderingCheckEnabled) {
            require(
                IMigrationVaultState(orderingVault).consumedNullifiers(
                    orderingNullifier
                ),
                "nullifier not consumed before transfer"
            );
            require(
                IMigrationVaultState(orderingVault).claimedUnits() ==
                    orderingClaimedUnits,
                "claimedUnits not updated before transfer"
            );
        }

        if (returnFalseTransfers) {
            return false;
        }

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value)
        external
        override
        returns (bool)
    {
        allowance[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value)
        external
        override
        returns (bool)
    {
        uint256 currentAllowance = allowance[from][msg.sender];
        require(currentAllowance >= value, "allowance");
        allowance[from][msg.sender] = currentAllowance - value;
        emit Approval(from, msg.sender, allowance[from][msg.sender]);
        _transfer(from, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "zero");
        uint256 fromBalance = balanceOf[from];
        require(fromBalance >= value, "balance");
        balanceOf[from] = fromBalance - value;
        balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
}

abstract contract MigrationVaultTestBase is Test {
    uint256 internal constant ROBINHOOD_CHAIN_ID = 4663;
    uint64 internal constant GENESIS_AMOUNT = 999_997_438_658_454;
    bytes32 internal constant MIGRATION_ID = keccak256("UTTC_R3_MIGRATION");
    bytes32 internal constant OTHER_MIGRATION_ID =
        keccak256("UTTC_R3_OTHER_MIGRATION");

    bytes32 internal constant ENTITLEMENT_A =
        keccak256("UTTC_R3_ENTITLEMENT_A");
    bytes32 internal constant ENTITLEMENT_B =
        keccak256("UTTC_R3_ENTITLEMENT_B");

    bytes32 internal constant SOURCE_PROOF_A =
        keccak256("UTTC_R3_SOURCE_PROOF_A");
    bytes32 internal constant SOURCE_PROOF_B =
        keccak256("UTTC_R3_SOURCE_PROOF_B");

    address internal constant DESTINATION_A = address(0xA11CE);
    address internal constant DESTINATION_B = address(0xB0B);

    uint64 internal constant AMOUNT_A = 125_000_000;
    uint64 internal constant AMOUNT_B = 375_000_000;

    MockRegistrationRootRegistry internal mockRegistry;
    MigrationVault internal vault;
    MockMigrationToken internal token;

    bytes32 internal economicLeafA;
    bytes32 internal economicLeafB;
    bytes32 internal economicRoot;

    bytes32 internal registrationLeafA;
    bytes32 internal registrationLeafB;
    bytes32 internal registrationRootEpoch1;

    function setUp() public virtual {
        vm.chainId(ROBINHOOD_CHAIN_ID);

        economicLeafA = UTTTMigrationHashing.economicLeaf(
            MIGRATION_ID,
            ENTITLEMENT_A,
            AMOUNT_A
        );
        economicLeafB = UTTTMigrationHashing.economicLeaf(
            MIGRATION_ID,
            ENTITLEMENT_B,
            AMOUNT_B
        );
        economicRoot = _hashPair(economicLeafA, economicLeafB);

        registrationLeafA = UTTTMigrationHashing.registrationLeaf(
            MIGRATION_ID,
            ENTITLEMENT_A,
            DESTINATION_A,
            SOURCE_PROOF_A,
            1
        );
        registrationLeafB = UTTTMigrationHashing.registrationLeaf(
            MIGRATION_ID,
            ENTITLEMENT_B,
            DESTINATION_B,
            SOURCE_PROOF_B,
            1
        );
        registrationRootEpoch1 =
            _hashPair(registrationLeafA, registrationLeafB);

        mockRegistry = new MockRegistrationRootRegistry(MIGRATION_ID);
        mockRegistry.setAcceptedRoot(registrationRootEpoch1, 1);

        vault = _newVault(
            economicRoot,
            MIGRATION_ID,
            address(mockRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
    }

    function _newVault(
        bytes32 economicRoot_,
        bytes32 migrationId_,
        address registry_,
        uint64 genesisAmount_,
        address factory_
    ) internal returns (MigrationVault) {
        return new MigrationVault(
            migrationId_,
            economicRoot_,
            RegistrationRootRegistry(registry_),
            genesisAmount_,
            factory_
        );
    }

    function _deployExactToken(MigrationVault targetVault)
        internal
        returns (MockMigrationToken)
    {
        return new MockMigrationToken(
            "Unified Trading Terminal Token",
            "UTTT",
            6,
            GENESIS_AMOUNT,
            address(targetVault)
        );
    }

    function _bindExactToken(MigrationVault targetVault)
        internal
        returns (MockMigrationToken boundToken)
    {
        boundToken = _deployExactToken(targetVault);
        targetVault.bindCanonicalToken(address(boundToken));
    }

    function _hashPair(bytes32 a, bytes32 b)
        internal
        pure
        returns (bytes32)
    {
        return a < b
            ? keccak256(bytes.concat(a, b))
            : keccak256(bytes.concat(b, a));
    }

    function _proof(bytes32 sibling)
        internal
        pure
        returns (bytes32[] memory result)
    {
        result = new bytes32[](1);
        result[0] = sibling;
    }

    function _emptyProof()
        internal
        pure
        returns (bytes32[] memory result)
    {
        result = new bytes32[](0);
    }

    function _claimA(
        MigrationVault targetVault,
        bytes32 registrationRoot,
        uint256 registrationEpoch,
        bytes32[] memory registrationProof
    ) internal {
        bytes32[] memory economicProof = _proof(economicLeafB);
        vm.prank(DESTINATION_A);
        targetVault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            registrationEpoch,
            registrationRoot,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            registrationProof
        );
    }
}

contract MigrationVaultCoreTest is MigrationVaultTestBase {
    function test_constructorBindsCoreState() public view {
        assertEq(vault.migrationId(), MIGRATION_ID);
        assertEq(vault.economicRoot(), economicRoot);
        assertEq(address(vault.registrationRegistry()), address(mockRegistry));
        assertEq(
            vault.canonicalGenesisAmount(),
            GENESIS_AMOUNT
        );
        assertEq(vault.factory(), address(this));
        assertEq(vault.canonicalToken(), address(0));
        assertEq(vault.claimedUnits(), 0);
    }

    function test_constructorRejectsWrongChain() public {
        vm.chainId(1);
        vm.expectRevert(
            abi.encodeWithSelector(MigrationVault.WrongChain.selector, 1)
        );
        _newVault(
            economicRoot,
            MIGRATION_ID,
            address(mockRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
    }

    function test_constructorRejectsZeroMigrationId() public {
        MockRegistrationRootRegistry zeroRegistry =
            new MockRegistrationRootRegistry(bytes32(0));

        vm.expectRevert(MigrationVault.ZeroMigrationId.selector);
        _newVault(
            economicRoot,
            bytes32(0),
            address(zeroRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
    }

    function test_constructorRejectsZeroEconomicRoot() public {
        vm.expectRevert(MigrationVault.ZeroEconomicRoot.selector);
        _newVault(
            bytes32(0),
            MIGRATION_ID,
            address(mockRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
    }

    function test_constructorRejectsZeroRegistry() public {
        vm.expectRevert(MigrationVault.ZeroRegistrationRegistry.selector);
        _newVault(
            economicRoot,
            MIGRATION_ID,
            address(0),
            GENESIS_AMOUNT,
            address(this)
        );
    }

    function test_constructorRejectsRegistryWithoutCode() public {
        address noCode = address(0x1234);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.RegistrationRegistryHasNoCode.selector,
                noCode
            )
        );
        _newVault(
            economicRoot,
            MIGRATION_ID,
            noCode,
            GENESIS_AMOUNT,
            address(this)
        );
    }

    function test_constructorRejectsRegistryMigrationMismatch() public {
        MockRegistrationRootRegistry wrongRegistry =
            new MockRegistrationRootRegistry(OTHER_MIGRATION_ID);

        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.RegistrationRegistryMigrationMismatch.selector,
                MIGRATION_ID,
                OTHER_MIGRATION_ID
            )
        );
        _newVault(
            economicRoot,
            MIGRATION_ID,
            address(wrongRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
    }

    function test_constructorRejectsWrongGenesisAmount() public {
        uint64 wrongAmount =
            GENESIS_AMOUNT - uint64(1);

        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.InvalidCanonicalGenesisAmount.selector,
                uint256(GENESIS_AMOUNT),
                uint256(wrongAmount)
            )
        );
        _newVault(
            economicRoot,
            MIGRATION_ID,
            address(mockRegistry),
            wrongAmount,
            address(this)
        );
    }

    function test_constructorRejectsZeroFactory() public {
        vm.expectRevert(MigrationVault.ZeroFactory.selector);
        _newVault(
            economicRoot,
            MIGRATION_ID,
            address(mockRegistry),
            GENESIS_AMOUNT,
            address(0)
        );
    }

    function test_constructorAcceptsPublishedRegistryInterface() public {
        address[5] memory reviewers_;
        reviewers_[0] = address(0x1001);
        reviewers_[1] = address(0x1002);
        reviewers_[2] = address(0x1003);
        reviewers_[3] = address(0x1004);
        reviewers_[4] = address(0x1005);

        RegistrationRootRegistry actualRegistry =
            new RegistrationRootRegistry(MIGRATION_ID, reviewers_);

        MigrationVault actualVault = _newVault(
            economicRoot,
            MIGRATION_ID,
            address(actualRegistry),
            GENESIS_AMOUNT,
            address(this)
        );

        assertEq(
            address(actualVault.registrationRegistry()),
            address(actualRegistry)
        );
        assertEq(actualVault.migrationId(), MIGRATION_ID);
    }

    function test_bindCanonicalTokenRequiresFactory() public {
        MockMigrationToken exactToken = _deployExactToken(vault);

        address outsider = address(0xCAFE);
        vm.prank(outsider);
        vm.expectRevert(
            abi.encodeWithSelector(MigrationVault.OnlyFactory.selector, outsider)
        );
        vault.bindCanonicalToken(address(exactToken));
    }

    function test_bindCanonicalTokenRejectsZeroOrNoCode() public {
        vm.expectRevert(MigrationVault.ZeroCanonicalToken.selector);
        vault.bindCanonicalToken(address(0));

        address noCode = address(0x9999);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.CanonicalTokenHasNoCode.selector,
                noCode
            )
        );
        vault.bindCanonicalToken(noCode);
    }

    function test_bindCanonicalTokenRejectsWrongNameSymbolAndDecimals() public {
        MigrationVault nameVault = _newVault(
            economicRoot,
            MIGRATION_ID,
            address(mockRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
        MockMigrationToken wrongName = new MockMigrationToken(
            "Wrong",
            "UTTT",
            6,
            GENESIS_AMOUNT,
            address(nameVault)
        );
        vm.expectRevert(MigrationVault.CanonicalTokenNameMismatch.selector);
        nameVault.bindCanonicalToken(address(wrongName));

        MigrationVault symbolVault = _newVault(
            economicRoot,
            MIGRATION_ID,
            address(mockRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
        MockMigrationToken wrongSymbol = new MockMigrationToken(
            "Unified Trading Terminal Token",
            "WRONG",
            6,
            GENESIS_AMOUNT,
            address(symbolVault)
        );
        vm.expectRevert(MigrationVault.CanonicalTokenSymbolMismatch.selector);
        symbolVault.bindCanonicalToken(address(wrongSymbol));

        MigrationVault decimalsVault = _newVault(
            economicRoot,
            MIGRATION_ID,
            address(mockRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
        MockMigrationToken wrongDecimals = new MockMigrationToken(
            "Unified Trading Terminal Token",
            "UTTT",
            18,
            GENESIS_AMOUNT,
            address(decimalsVault)
        );
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.CanonicalTokenDecimalsMismatch.selector,
                uint8(6),
                uint8(18)
            )
        );
        decimalsVault.bindCanonicalToken(address(wrongDecimals));
    }

    function test_bindCanonicalTokenRejectsWrongSupply() public {
        MockMigrationToken wrongSupply = new MockMigrationToken(
            "Unified Trading Terminal Token",
            "UTTT",
            6,
            uint256(GENESIS_AMOUNT) - 1,
            address(vault)
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.CanonicalTokenSupplyMismatch.selector,
                uint256(GENESIS_AMOUNT),
                uint256(GENESIS_AMOUNT) - 1
            )
        );
        vault.bindCanonicalToken(address(wrongSupply));
    }

    function test_bindCanonicalTokenRejectsIncompleteVaultBalance() public {
        MockMigrationToken incompleteBalance = new MockMigrationToken(
            "Unified Trading Terminal Token",
            "UTTT",
            6,
            GENESIS_AMOUNT,
            address(this)
        );

        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.CanonicalTokenVaultBalanceMismatch.selector,
                uint256(GENESIS_AMOUNT),
                uint256(0)
            )
        );
        vault.bindCanonicalToken(address(incompleteBalance));
    }

    function test_bindCanonicalTokenSucceedsAndCannotRebind() public {
        MockMigrationToken exactToken = _bindExactToken(vault);
        assertEq(vault.canonicalToken(), address(exactToken));

        MockMigrationToken secondToken = _deployExactToken(vault);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.CanonicalTokenAlreadyBound.selector,
                address(exactToken)
            )
        );
        vault.bindCanonicalToken(address(secondToken));
    }
}

contract MigrationVaultClaimTest is MigrationVaultTestBase {
    function setUp() public override {
        super.setUp();
        token = _bindExactToken(vault);
    }

    function test_claimRequiresTokenBound() public {
        MigrationVault unboundVault = _newVault(
            economicRoot,
            MIGRATION_ID,
            address(mockRegistry),
            GENESIS_AMOUNT,
            address(this)
        );

        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32[] memory registrationProof = _proof(registrationLeafB);

        vm.prank(DESTINATION_A);
        vm.expectRevert(MigrationVault.CanonicalTokenNotBound.selector);
        unboundVault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            1,
            registrationRootEpoch1,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            registrationProof
        );
    }

    function test_claimValidSortedPairProofTransfersFullEntitlement() public {
        bytes32[] memory registrationProof = _proof(registrationLeafB);
        _claimA(vault, registrationRootEpoch1, 1, registrationProof);

        bytes32 nullifier =
            UTTTMigrationHashing.nullifier(MIGRATION_ID, ENTITLEMENT_A);

        assertTrue(vault.consumedNullifiers(nullifier));
        assertEq(vault.claimedUnits(), AMOUNT_A);
        assertEq(token.balanceOf(DESTINATION_A), AMOUNT_A);
        assertEq(
            token.balanceOf(address(vault)),
            uint256(GENESIS_AMOUNT) - AMOUNT_A
        );
    }

    function test_claimRequiresDestinationCaller() public {
        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32[] memory registrationProof = _proof(registrationLeafB);

        address caller = address(0xDEAD);
        vm.prank(caller);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.DestinationCallerMismatch.selector,
                DESTINATION_A,
                caller
            )
        );
        vault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            1,
            registrationRootEpoch1,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            registrationProof
        );
    }

    function test_claimRejectsUnacceptedRegistrationRoot() public {
        bytes32 unacceptedRoot = keccak256("UNACCEPTED");
        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32[] memory registrationProof = _proof(registrationLeafB);

        vm.prank(DESTINATION_A);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.RegistrationRootNotAccepted.selector,
                unacceptedRoot,
                uint256(1),
                uint256(0)
            )
        );
        vault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            1,
            unacceptedRoot,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            registrationProof
        );
    }

    function test_claimRejectsAcceptedRootWrongEpoch() public {
        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32[] memory registrationProof = _proof(registrationLeafB);

        vm.prank(DESTINATION_A);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.RegistrationRootNotAccepted.selector,
                registrationRootEpoch1,
                uint256(2),
                uint256(1)
            )
        );
        vault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            2,
            registrationRootEpoch1,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            registrationProof
        );
    }

    function test_claimRejectsInvalidEconomicProof() public {
        bytes32[] memory badEconomicProof = _proof(bytes32(uint256(123)));
        bytes32[] memory registrationProof = _proof(registrationLeafB);

        vm.prank(DESTINATION_A);
        vm.expectRevert(MigrationVault.InvalidEconomicProof.selector);
        vault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            1,
            registrationRootEpoch1,
            DESTINATION_A,
            SOURCE_PROOF_A,
            badEconomicProof,
            registrationProof
        );
    }

    function testFuzz_wrongAmountCannotClaim(uint64 wrongAmount) public {
        vm.assume(wrongAmount != AMOUNT_A);

        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32[] memory registrationProof = _proof(registrationLeafB);

        vm.prank(DESTINATION_A);
        vm.expectRevert(MigrationVault.InvalidEconomicProof.selector);
        vault.claim(
            ENTITLEMENT_A,
            wrongAmount,
            1,
            registrationRootEpoch1,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            registrationProof
        );
    }

    function test_claimRejectsInvalidRegistrationProof() public {
        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32[] memory badRegistrationProof = _proof(bytes32(uint256(456)));

        vm.prank(DESTINATION_A);
        vm.expectRevert(MigrationVault.InvalidRegistrationProof.selector);
        vault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            1,
            registrationRootEpoch1,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            badRegistrationProof
        );
    }

    function test_claimReplayBlockedByGlobalNullifier() public {
        bytes32[] memory registrationProof = _proof(registrationLeafB);
        _claimA(vault, registrationRootEpoch1, 1, registrationProof);

        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32 nullifier =
            UTTTMigrationHashing.nullifier(MIGRATION_ID, ENTITLEMENT_A);

        vm.prank(DESTINATION_A);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.EntitlementAlreadyClaimed.selector,
                ENTITLEMENT_A,
                nullifier
            )
        );
        vault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            1,
            registrationRootEpoch1,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            registrationProof
        );
    }

    function test_claimSameEntitlementAcrossSupplementalEpochStillBlocked()
        public
    {
        bytes32[] memory registrationProofEpoch1 = _proof(registrationLeafB);
        _claimA(
            vault,
            registrationRootEpoch1,
            1,
            registrationProofEpoch1
        );

        bytes32 sourceProofEpoch2 = keccak256("UTTC_R3_SOURCE_PROOF_A_EPOCH2");
        bytes32 registrationLeafEpoch2 =
            UTTTMigrationHashing.registrationLeaf(
                MIGRATION_ID,
                ENTITLEMENT_A,
                DESTINATION_A,
                sourceProofEpoch2,
                2
            );
        bytes32 registrationRootEpoch2 = registrationLeafEpoch2;
        mockRegistry.setAcceptedRoot(registrationRootEpoch2, 2);

        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32[] memory registrationProofEpoch2 = _emptyProof();
        bytes32 nullifier =
            UTTTMigrationHashing.nullifier(MIGRATION_ID, ENTITLEMENT_A);

        vm.prank(DESTINATION_A);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.EntitlementAlreadyClaimed.selector,
                ENTITLEMENT_A,
                nullifier
            )
        );
        vault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            2,
            registrationRootEpoch2,
            DESTINATION_A,
            sourceProofEpoch2,
            economicProof,
            registrationProofEpoch2
        );
    }

    function test_claimDifferentEntitlementsAccumulateMonotonically() public {
        bytes32[] memory registrationProofA = _proof(registrationLeafB);
        _claimA(vault, registrationRootEpoch1, 1, registrationProofA);

        bytes32[] memory economicProofB = _proof(economicLeafA);
        bytes32[] memory registrationProofB = _proof(registrationLeafA);

        vm.prank(DESTINATION_B);
        vault.claim(
            ENTITLEMENT_B,
            AMOUNT_B,
            1,
            registrationRootEpoch1,
            DESTINATION_B,
            SOURCE_PROOF_B,
            economicProofB,
            registrationProofB
        );

        assertEq(vault.claimedUnits(), uint256(AMOUNT_A) + uint256(AMOUNT_B));
        assertEq(token.balanceOf(DESTINATION_A), AMOUNT_A);
        assertEq(token.balanceOf(DESTINATION_B), AMOUNT_B);
    }

    function test_claimCapCannotExceedCanonicalGenesisAmount() public {
        uint64 tooLarge =
            GENESIS_AMOUNT + uint64(1);

        bytes32 oversizedLeaf = UTTTMigrationHashing.economicLeaf(
            MIGRATION_ID,
            ENTITLEMENT_A,
            tooLarge
        );

        bytes32 oversizedRegistrationLeaf =
            UTTTMigrationHashing.registrationLeaf(
                MIGRATION_ID,
                ENTITLEMENT_A,
                DESTINATION_A,
                SOURCE_PROOF_A,
                9
            );

        MockRegistrationRootRegistry localRegistry =
            new MockRegistrationRootRegistry(MIGRATION_ID);
        localRegistry.setAcceptedRoot(oversizedRegistrationLeaf, 9);

        MigrationVault localVault = _newVault(
            oversizedLeaf,
            MIGRATION_ID,
            address(localRegistry),
            GENESIS_AMOUNT,
            address(this)
        );
        _bindExactToken(localVault);

        bytes32[] memory emptyProof = _emptyProof();

        vm.prank(DESTINATION_A);
        vm.expectRevert(
            abi.encodeWithSelector(
                MigrationVault.ClaimedUnitsExceedGenesis.selector,
                uint256(tooLarge),
                uint256(GENESIS_AMOUNT)
            )
        );
        localVault.claim(
            ENTITLEMENT_A,
            tooLarge,
            9,
            oversizedRegistrationLeaf,
            DESTINATION_A,
            SOURCE_PROOF_A,
            emptyProof,
            emptyProof
        );
    }

    function test_claimMarksStateBeforeTokenTransfer() public {
        bytes32 nullifier =
            UTTTMigrationHashing.nullifier(MIGRATION_ID, ENTITLEMENT_A);

        token.configureOrderingCheck(
            address(vault),
            nullifier,
            uint256(AMOUNT_A)
        );

        bytes32[] memory registrationProof = _proof(registrationLeafB);
        _claimA(vault, registrationRootEpoch1, 1, registrationProof);

        assertTrue(vault.consumedNullifiers(nullifier));
        assertEq(vault.claimedUnits(), AMOUNT_A);
    }

    function test_claimTransferFailureRollsBackNullifierAndClaimedUnits()
        public
    {
        token.configureReturnFalseTransfers(true);

        bytes32 nullifier =
            UTTTMigrationHashing.nullifier(MIGRATION_ID, ENTITLEMENT_A);
        bytes32[] memory economicProof = _proof(economicLeafB);
        bytes32[] memory registrationProof = _proof(registrationLeafB);

        vm.prank(DESTINATION_A);
        vm.expectRevert();
        vault.claim(
            ENTITLEMENT_A,
            AMOUNT_A,
            1,
            registrationRootEpoch1,
            DESTINATION_A,
            SOURCE_PROOF_A,
            economicProof,
            registrationProof
        );

        assertFalse(vault.consumedNullifiers(nullifier));
        assertEq(vault.claimedUnits(), 0);
        assertEq(token.balanceOf(DESTINATION_A), 0);
        assertEq(
            token.balanceOf(address(vault)),
            GENESIS_AMOUNT
        );
    }
}
