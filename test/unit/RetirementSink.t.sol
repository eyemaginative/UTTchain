// SPDX-License-Identifier: MIT
pragma solidity 0.8.36;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {RetirementSink} from "../../src/settlement/RetirementSink.sol";

contract MockLegacyUTTT is ERC20 {
    constructor(uint256 amount) ERC20("Legacy UTTT", "UTTT") {
        _mint(msg.sender, amount);
    }
}

contract RetirementSinkTest is Test {
    uint256 internal constant LEGACY_SUPPLY = 420_000_000 ether;
    uint256 internal constant RETIRE_AMOUNT = 1_000_000 ether;

    RetirementSink internal sink;
    MockLegacyUTTT internal legacy;

    function setUp() public {
        sink = new RetirementSink();
        legacy = new MockLegacyUTTT(LEGACY_SUPPLY);
    }

    function test_runtimeCodePresentAndStableAcrossDeployments() public {
        RetirementSink second = new RetirementSink();

        assertGt(address(sink).code.length, 0);
        assertEq(address(sink).codehash, address(second).codehash);
    }

    function test_initialAdministrativeStorageIsZero() public view {
        assertEq(vm.load(address(sink), bytes32(uint256(0))), bytes32(0));
        assertEq(vm.load(address(sink), bytes32(uint256(1))), bytes32(0));
        assertEq(vm.load(address(sink), bytes32(uint256(2))), bytes32(0));
        assertEq(vm.load(address(sink), bytes32(uint256(3))), bytes32(0));
    }

    function test_rejectsArbitraryCalldata() public {
        (bool success,) = address(sink).call(hex"deadbeef");
        assertFalse(success);
    }

    function test_rejectsNativeEth() public {
        vm.deal(address(this), 1 ether);

        // Expected rejection path: ETH send is intentional test input.
        // forge-lint: disable-next-line(arbitrary-send-eth)
        (bool success,) = address(sink).call{value: 1}("");

        assertFalse(success);
        assertEq(address(sink).balance, 0);
    }

    function test_acceptsLegacyERC20RetirementWithoutRecipientExecution() public {
        uint256 supplyBefore = legacy.totalSupply();

        assertTrue(legacy.transfer(address(sink), RETIRE_AMOUNT));

        assertEq(legacy.balanceOf(address(sink)), RETIRE_AMOUNT);
        assertEq(legacy.balanceOf(address(this)), LEGACY_SUPPLY - RETIRE_AMOUNT);
        assertEq(legacy.totalSupply(), supplyBefore);
    }

    function test_arbitrarySinkCallCannotReleaseRetiredLegacyTokens() public {
        assertTrue(legacy.transfer(address(sink), RETIRE_AMOUNT));
        bytes memory attemptedRelease = abi.encodeCall(
            IERC20.transfer,
            (address(this), RETIRE_AMOUNT)
        );

        (bool success,) = address(sink).call(attemptedRelease);

        assertFalse(success);
        assertEq(legacy.balanceOf(address(sink)), RETIRE_AMOUNT);
        assertEq(legacy.balanceOf(address(this)), LEGACY_SUPPLY - RETIRE_AMOUNT);
    }

    function test_retirementSinkHasNoNativeBalanceAfterRejectedCalls() public {
        vm.deal(address(this), 2);
        // Expected rejection paths: ETH sends are intentional test inputs.
        // forge-lint: disable-next-line(arbitrary-send-eth)
        (bool first,) = address(sink).call{value: 1}("");
        // forge-lint: disable-next-line(arbitrary-send-eth)
        (bool second,) = address(sink).call{value: 1}(hex"01");

        assertFalse(first);
        assertFalse(second);
        assertEq(address(sink).balance, 0);
    }

    function testFuzz_legacyERC20RetirementPreservesSupply(uint256 amount) public {
        amount = bound(amount, 1, LEGACY_SUPPLY);
        uint256 supplyBefore = legacy.totalSupply();

        assertTrue(legacy.transfer(address(sink), amount));

        assertEq(legacy.balanceOf(address(sink)), amount);
        assertEq(legacy.totalSupply(), supplyBefore);
    }
}
