// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";
import "./interfaces/IERC20.sol";
import "./interfaces/IUniswapV3Pool.sol";
import "./libraries/PoolAddress.sol";
import "./interfaces/IWETH.sol";

contract Flashloan {

    address private owner;

    address private constant FACTORY =
        0x1F98431c8aD98523631AE4a59f267346ea31F984;

    address private constant  WETH_ADDR =
    0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

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

    function initArbPool(address _token0, address _token1, uint24 _fee) external onlyOwner {
		token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        pool = IUniswapV3Pool(getPool(_token0, _token1, _fee));
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


    receive() external payable {}


    function withdraw(uint256 amount) public onlyOwner {
        address payable to = payable(owner);
        to.transfer(amount);
    }

    function ethBalance() external onlyOwner view returns(uint256)  {
        return address(this).balance;
    }

    function wethBalance() external onlyOwner view returns(uint256) {
        return IWETH9(WETH_ADDR).balanceOf(address(this));
    }

    function unwrapEther(uint256 amount) external onlyOwner {
        if (amount != 0) {
            IWETH9(WETH_ADDR).withdraw(amount);
        }
    }

    function flash(uint256 amount0, uint256 amount1) external onlyOwner {
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
        console.log("Balance of token1:"); 
        console.log(token1.balanceOf(address(this)));//1000000000000000000

        // Repay borrow
        if (fee0 > 0) {
            token0.transferFrom(decoded.caller, address(this), fee0);
            token0.transfer(address(pool), decoded.amount0 + fee0);
        }
        if (fee1 > 0) {
            //FROM: decoded.caller = 0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266 (Forking Account #0)
            //TO:   address(this) = flashloan.target (deployed address)
            //decoded.amount1 = 1000000000000000000

            //Transfer fee from owner's wallet to the contract
            token1.transferFrom(decoded.caller, address(this), fee1);
            //Paying off the loan (back to the pool) with fee
            token1.transfer(address(pool), decoded.amount1 + fee1);
            console.log("Balance of token1:"); 
            console.log(token1.balanceOf(address(this))); //0
        }

        // console.log("Fee0:");
        // console.log(fee0);//0
        // console.log("Fee1:");
        // console.log(fee1);//3000000000000000 - 0.003 ETH
    }

    modifier onlyOwner {
		require(msg.sender == owner, "Only onwer may call this function!");
		_;
	}
}







