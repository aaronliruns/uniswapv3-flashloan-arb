// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./interfaces/IERC20.sol";
import "./interfaces/IWETH.sol";
import "./interfaces/ISwapRouter02.sol";

//https://docs.uniswap.org/contracts/v2/reference/smart-contracts/router-02
address constant SWAP_ROUTER_02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
address constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

contract MultiHopSwap {
    ISwapRouter02 private constant router = ISwapRouter02(SWAP_ROUTER_02);
    IWETH private constant weth = IWETH(WETH);
    IERC20 private constant dai = IERC20(DAI);

    function swapExactInputMultiHop(uint256 amountIn, uint256 amountOutMin)
        external
    {
        weth.transferFrom(msg.sender, address(this), amountIn);
        weth.approve(address(router), amountIn);

        bytes memory path =
            abi.encodePacked(WETH, uint24(3000), USDC, uint24(100), DAI);

        ISwapRouter02.ExactInputParams memory params = ISwapRouter02
            .ExactInputParams({
            path: path,
            recipient: msg.sender,
            amountIn: amountIn,
            amountOutMinimum: amountOutMin
        });

        router.exactInput(params);
    }
}

// function test_swapExactInputMultiHop() public {
//         swap.swapExactInputMultiHop(AMOUNT_IN, 1);
//         uint256 d1 = dai.balanceOf(address(this));
//         assertGt(d1, 0, "DAI balance = 0");
// }