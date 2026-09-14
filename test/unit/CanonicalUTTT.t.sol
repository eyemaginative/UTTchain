// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Test} from "forge-std/Test.sol";

import {CanonicalUTTT} from "../../src/token/CanonicalUTTT.sol";
import {MigrationVault} from "../../src/token/MigrationVault.sol";
import {RegistrationRootRegistry} from "../../src/registry/RegistrationRootRegistry.sol";

contract MockCanonicalTokenRegistrationRegistry {
    bytes32 public immutable migrationId;
    mapping(bytes32 root => uint256 epoch) public acceptedRootEpoch;

    constructor(bytes32 migrationId_) {
        migrationId = migrationId_;
    }
}

contract CanonicalUTTTSpender {
    function pull(
        CanonicalUTTT token,
        address to,
        uint256 amount
    ) external returns (bool) {
        return token.transferFrom(msg.sender, to, amount);
    }
}

contract CanonicalUTTTTest is Test {
    uint256 internal constant ROBINHOOD_CHAIN_ID = 4663;
    uint256 internal constant GENESIS_SUPPLY = 999_997_438_658_454;
    uint64 internal constant GENESIS_SUPPLY_U64 = 999_997_438_658_454;

    address internal constant GENESIS_VAULT = address(0xBEEF);
    address internal constant RECIPIENT = address(0xCAFE);

    CanonicalUTTT internal token;
    CanonicalUTTTSpender internal spender;

    function setUp() public {
        vm.chainId(ROBINHOOD_CHAIN_ID);
        token = new CanonicalUTTT(GENESIS_VAULT);
        spender = new CanonicalUTTTSpender();
    }

    function test_metadataExact() public view {
        assertEq(token.name(), "Unified Trading Terminal Token");
        assertEq(token.symbol(), "UTTT");
        assertEq(token.decimals(), 6);
    }

    function test_chainConstantExact() public view {
        assertEq(token.ROBINHOOD_CHAIN_ID(), ROBINHOOD_CHAIN_ID);
    }

    function test_genesisSupplyConstantExact() public view {
        assertEq(token.CANONICAL_GENESIS_SUPPLY(), GENESIS_SUPPLY);
        assertEq(token.CANONICAL_DECIMALS(), 6);
    }

    function test_entireGenesisSupplyMintedToVault() public view {
        assertEq(token.totalSupply(), GENESIS_SUPPLY);
        assertEq(token.balanceOf(GENESIS_VAULT), GENESIS_SUPPLY);
        assertEq(token.balanceOf(address(this)), 0);
    }

    function test_constructorRejectsZeroVault() public {
        vm.expectRevert(CanonicalUTTT.ZeroMigrationVault.selector);
        new CanonicalUTTT(address(0));
    }

    function test_constructorRejectsWrongChain() public {
        vm.chainId(1);
        vm.expectRevert(
            abi.encodeWithSelector(
                CanonicalUTTT.WrongChain.selector,
                uint256(1)
            )
        );
        new CanonicalUTTT(GENESIS_VAULT);
    }

    function test_transferUsesStandardERC20Accounting() public {
        vm.prank(GENESIS_VAULT);
        assertTrue(token.transfer(RECIPIENT, 123_456));

        assertEq(token.balanceOf(RECIPIENT), 123_456);
        assertEq(
            token.balanceOf(GENESIS_VAULT),
            GENESIS_SUPPLY - 123_456
        );
        assertEq(token.totalSupply(), GENESIS_SUPPLY);
    }

    function test_approveAndTransferFromUseStandardERC20Accounting() public {
        vm.prank(GENESIS_VAULT);
        assertTrue(token.approve(address(spender), 500_000));

        vm.prank(GENESIS_VAULT);
        assertTrue(spender.pull(token, RECIPIENT, 200_000));

        assertEq(
            token.allowance(GENESIS_VAULT, address(spender)),
            300_000
        );
        assertEq(token.balanceOf(RECIPIENT), 200_000);
        assertEq(token.totalSupply(), GENESIS_SUPPLY);
    }

    function test_approvalDoesNotChangeSupplyOrBalances() public {
        vm.prank(GENESIS_VAULT);
        assertTrue(token.approve(address(spender), GENESIS_SUPPLY));

        assertEq(token.allowance(GENESIS_VAULT, address(spender)), GENESIS_SUPPLY);
        assertEq(token.balanceOf(GENESIS_VAULT), GENESIS_SUPPLY);
        assertEq(token.totalSupply(), GENESIS_SUPPLY);
    }

    function test_transferCannotExceedBalance() public {
        vm.prank(RECIPIENT);
        vm.expectRevert();
        // Expected-revert path: the ERC20 return value is intentionally unreachable.
        // forge-lint: disable-next-line(erc20-unchecked-transfer)
        token.transfer(GENESIS_VAULT, 1);
    }

    function test_transferFromCannotExceedAllowance() public {
        vm.prank(GENESIS_VAULT);
        assertTrue(token.approve(address(spender), 1));

        vm.prank(GENESIS_VAULT);
        vm.expectRevert();
        // Expected-revert path: the helper return value is intentionally unreachable.
        // forge-lint: disable-next-line(unused-return)
        spender.pull(token, RECIPIENT, 2);
    }

    function testFuzz_transferPreservesFixedSupply(uint256 amount) public {
        amount = bound(amount, 0, GENESIS_SUPPLY);

        vm.prank(GENESIS_VAULT);
        assertTrue(token.transfer(RECIPIENT, amount));

        assertEq(token.totalSupply(), GENESIS_SUPPLY);
        assertEq(
            token.balanceOf(GENESIS_VAULT) + token.balanceOf(RECIPIENT),
            GENESIS_SUPPLY
        );
    }

    function testFuzz_transferFromPreservesFixedSupply(uint256 amount) public {
        amount = bound(amount, 0, GENESIS_SUPPLY);

        vm.prank(GENESIS_VAULT);
        assertTrue(token.approve(address(spender), amount));

        vm.prank(GENESIS_VAULT);
        assertTrue(spender.pull(token, RECIPIENT, amount));

        assertEq(token.totalSupply(), GENESIS_SUPPLY);
        assertEq(
            token.balanceOf(GENESIS_VAULT) + token.balanceOf(RECIPIENT),
            GENESIS_SUPPLY
        );
    }

    function test_publishedMigrationVaultAcceptsCanonicalTokenBinding() public {
        bytes32 migrationId = keccak256("R4_BINDING_MIGRATION");
        bytes32 economicRoot = keccak256("R4_BINDING_ECONOMIC_ROOT");

        MockCanonicalTokenRegistrationRegistry registry =
            new MockCanonicalTokenRegistrationRegistry(migrationId);

        MigrationVault vault = new MigrationVault(
            migrationId,
            economicRoot,
            RegistrationRootRegistry(address(registry)),
            GENESIS_SUPPLY_U64,
            address(this)
        );

        CanonicalUTTT canonical = new CanonicalUTTT(address(vault));

        assertEq(canonical.totalSupply(), GENESIS_SUPPLY);
        assertEq(canonical.balanceOf(address(vault)), GENESIS_SUPPLY);

        vault.bindCanonicalToken(address(canonical));

        assertEq(vault.canonicalToken(), address(canonical));
        assertEq(canonical.balanceOf(address(vault)), GENESIS_SUPPLY);
        assertEq(canonical.totalSupply(), GENESIS_SUPPLY);
    }
}
