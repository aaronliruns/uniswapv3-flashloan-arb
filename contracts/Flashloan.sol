// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./libraries/PoolAddress.sol";

contract Flashloan {
    address private constant FACTORY =
        0x1F98431c8aD98523631AE4a59f267346ea31F984;

    struct FlashCallbackData {
        uint256 amount0;
        uint256 amount1;
        address caller;
    }

    IERC20 private immutable token0;
    IERC20 private immutable token1;

    IUniswapV3Pool private immutable pool;

    constructor(
        address _token0,
        address _token1,
        uint24 _fee
    ) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        pool = IUniswapV3Pool(getPool(_token0, _token1, _fee));
    }

    function getPool(
        address _token0,
        address _token1,
        uint24 _fee
    ) public pure returns (address) {
        PoolAddress.PoolKey memory poolKey = PoolAddress.getPoolKey(
            _token0,
            _token1,
            _fee
        );
        return PoolAddress.computeAddress(FACTORY, poolKey);
    }

    function flash(uint256 amount0, uint256 amount1) external {
        bytes memory data = abi.encode(
            FlashCallbackData({
                amount0: amount0,
                amount1: amount1,
                caller: msg.sender
            })
        );
        IUniswapV3Pool(pool).flash(address(this), amount0, amount1, data);
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

        // Do your abitrage below...

        console.log("Balance of token0:");
        console.log(token0.balanceOf(address(this)));
        console.log("Balance of token1:"); 
        console.log(token1.balanceOf(address(this)));

        // Repay borrow
        if (fee0 > 0) {
            token0.transferFrom(decoded.caller, address(this), fee0);
            token0.transfer(address(pool), decoded.amount0 + fee0);
        }
        if (fee1 > 0) {
            token1.transferFrom(decoded.caller, address(this), fee1);
            token1.transfer(address(pool), decoded.amount1 + fee1);
        }

        console.log("Fee0:");
        console.log(fee0);//0
        console.log("Fee1:");
        console.log(fee1);//3000000000000000 - 0.003 ETH
    }
}







