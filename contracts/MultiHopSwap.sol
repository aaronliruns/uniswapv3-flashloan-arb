// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./interfaces/IERC20.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/ISwapRouter02.sol";
import "./libraries/SafeERC20.sol";

//https://docs.uniswap.org/contracts/v3/reference/deployments/ethereum-deployments
//when router address is wrong
//Error: Transaction reverted without a reason string
address constant SWAP_ROUTER_02 = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

contract MultiHopSwap {

    using SafeERC20 for IERC20;

    ISwapRouter02 private constant ROUTER = ISwapRouter02(SWAP_ROUTER_02);
    uint256 private constant MAX_INT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    function swapExactInputMultiHop(uint256 amountIn) external {

        // execution reverted: STF means execution is reverted by require assertion in TransferHelper.safeTransferFrom function.
        IERC20(USDC).safeApprove(address(ROUTER), MAX_INT);
        IERC20(WETH).safeApprove(address(ROUTER), MAX_INT);
        IERC20(DAI).safeApprove(address(ROUTER), MAX_INT);

        bytes memory path =
            abi.encodePacked(USDC, uint24(3000), WETH, uint24(3000), DAI, uint24(3000), USDC) ;

        ISwapRouter02.ExactInputParams memory params = ISwapRouter02
            .ExactInputParams({
            path: path,
            recipient: address(this),
            amountIn: amountIn,
            amountOutMinimum: 1
        });

        ROUTER.exactInput(params);
    }

    function tokenBalance(address tokenAddress) external view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }
}
