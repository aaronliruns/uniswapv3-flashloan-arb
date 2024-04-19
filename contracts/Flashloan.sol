// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./libraries/PoolAddress.sol";
import "./interfaces/IWETH.sol";
import "./libraries/SafeERC20.sol";

contract Flashloan {

    using SafeERC20 for IERC20;

    address private owner;
    address private constant FACTORY =
        0x1F98431c8aD98523631AE4a59f267346ea31F984;

    address private constant  WETH_ADDR =
    0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    uint256 private constant MAX_INT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    address private constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    IERC20 private constant usdc = IERC20(USDC);

    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address caller;
    }

    IERC20 private  token0;
    IERC20 private  token1;

    IUniswapV3Pool private  pool;

	constructor() {
		owner = msg.sender;
	}


    function getPool(
        address _token0,
        address _token1,
        uint24 _fee
    ) private pure returns (address) {
        PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(
            _token0,
            _token1,
            _fee
        );
        return PoolAddress.computeAddress(FACTORY, poolKey);
    }

    function ethBalance() external onlyOwner view returns(uint256)  {
        return address(this).balance;
    }

    function wethBalance() external onlyOwner view returns(uint256) {
        return IWETH(WETH_ADDR).balanceOf(address(this));
    }

    function tokenBalance(address tokenAddress) external onlyOwner view returns (uint256) {
        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function flash(uint256 amount0, uint256 amount1) private onlyOwner {
        bytes memory data = abi.encode(
            FlashCallbackData({
                amount0: amount0,
                amount1: amount1,
                caller: address(this)
            })
        );
        pool.flash(address(this), amount0, amount1, data);
    }

    function initArbPool(address _token0, address _token1, uint24 _fee, uint256 amount0, uint256 amount1) external onlyOwner {
		token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        pool = IUniswapV3Pool(getPool(_token0, _token1, _fee));
        flash(amount0, amount1);
	}

    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external {
        require(msg.sender == address(pool), "not authorized");

        FlashCallbackData memory decoded = abi.decode(
            data,
            (FlashCallbackData)
        );

        // Repay borrow
        if (fee0 > 0) {
            console.log("tokenBorrowed0OnThisContract=",token0.balanceOf(address(this)));
            console.log("returning=", decoded.amount0 + fee0);
            token0.transfer(address(pool), decoded.amount0 + fee0);
        }
        if (fee1 > 0) {
            console.log("tokenBorrowed1OnThisContract=", IERC20(USDC).balanceOf(address(this)));
            console.log("returning=", decoded.amount1 + fee1);
            token1.transfer(address(pool), decoded.amount1 + fee1);
        }
    }
    


    modifier onlyOwner {
		require(msg.sender == owner, "Only onwer can call this function!");
		_;
	}
}