// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaSwap.sol";
import "../src/ICHI.sol";

contract MetaSwapTest is Test {
    MetaSwap metaswap;
    ICHI ichi;
    address owner;

    function setUp() public {
        //uint256 privateKey = uint256(keccak256(abi.encodePacked('')));
        owner = vm.addr(1);

        // Seed the account with funds
        vm.deal(owner, 10 ether);

        // DAI contract address
        ICHI dai = ICHI(0x6B175474E89094C44Da98b954EedeAC495271d0F);

        // Mint DAI for the owner (if using a mock DAI contract)
        vm.prank(owner);
        dai.mint(200000000000000000); // Mint 0.2 DAI

        // Check DAI balance
        uint256 daiBalance = dai.balanceOf(owner);
        require(daiBalance >= 200000000000000000, "Insufficient DAI balance");

        // Approve the Spender contract to spend DAI
        dai.approve(address(metaswap), 200000000000000000); // Approve 0.2 DAI

        // Deploy the Spender contract
        metaswap = new MetaSwap(ichi);
    }

    function testSwap() public {

        // Define parameters for the swap function
        string memory aggregatorId = "airSwap4_3FeeDynamic";
        address tokenFrom = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        uint256 amount = 200000000000000000; // 0.2 DAI
        bytes memory data = hex"00000000000000000000000000000000000000000000000000000194b1d970e10000000000000000000000000000000000000000000000000000000067b4836200000000000000000000000051c72848c68a965f66fa7a88855f9f7784502a7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000435578162d0c0000000000000000000000006b175474e89094c44da98b954eedeac495271d0f00000000000000000000000000000000000000000000000002c68af0bb140000000000000000000000000000000000000000000000000000000000000000001c071768c9b617aabc084ec2edb72260de70dfcf4e8181696d0da259ba5a55a23e2ae7308b0f565afb7a6120bb52c07f1d0a74326a23e0d70861b3c67219dfda0f00000000000000000000000000000000000000000000000000000096d3ee4627000000000000000000000000f326e4de8f66a0bdc0970b79e0924e33c79f19150000000000000000000000000000000000000000000000000000000000000001";

        // Encode the function call with the correct parameters
        bytes memory encodedFunctionCall = abi.encodeWithSignature(
            "swap(string,address,uint256,bytes)",
            aggregatorId,
            tokenFrom,
            amount,
            data
        );

        // Execute the swap function
        vm.startPrank(owner);
        (bool success, ) = address(metaswap).call(encodedFunctionCall);
        require(success, "Swap failed");
        vm.stopPrank();
    }
} 