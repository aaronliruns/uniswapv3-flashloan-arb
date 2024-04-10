const { ethers } = require("hardhat");
const { expect } = require("chai");
const { impersonateFundErc20 } = require("../utils/utilities");


const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const POOL_FEE = 3000; // 0.30% tier

const WETH_WHALE = "0xF04a5cC80B1E94C69B48f5ee68a08CD2F09A7c3E";




describe("UniswapV3Arb", function () {
  
  describe("UniswapV3MultiHopSwap", function () {
    let accounts, dai, weth;
    const initialFundingHuman = "0.03"; 
    const DECIMALS = 18; //WETH Demicals
    

    beforeEach(async function () {
      accounts = await ethers.getSigners();
      let dai = await ethers.getContractAt("IERC20", DAI);
      let weth = await ethers.getContractAt("IWETH", WETH);
      let usdc = await ethers.getContractAt("IERC20", USDC);

      console.log(
        "WETH balance of whale: ",
        await usdc.balanceOf(WETH_WHALE)
      );

      const Flashloan = await ethers.getContractFactory(
        "Flashloan"
      );

      flashloan = await Flashloan.deploy();
      await flashloan.waitForDeployment();
      
      console.log('Impersonation Started.')
      await impersonateFundErc20(
        weth,
        WETH_WHALE,
        flashloan.target,
        initialFundingHuman,
        DECIMALS
      );
      console.log('Impersonation completed.')

    });


  it("ensures contract is funded", async () => {
      const balOfWETHOnContract = await flashloan.tokenBalance(WETH);

      const flashSwapBalanceHuman = ethers.formatUnits(
        balOfWETHOnContract,
        DECIMALS
      );
      expect(Number(flashSwapBalanceHuman)).equal(Number(initialFundingHuman));
  });


  it("borrow WETH flash loan", async () => {
    balance = await flashloan.connect(accounts[0]).tokenBalance(WETH);
    console.log(`Current balance of WETH = ${balance}`);

    // Execute flashloan to borrow 1 WETH.
    await flashloan.connect(accounts[0]).initArbPool(USDC, WETH, POOL_FEE);
    await flashloan.connect(accounts[0]).flash(0, ethers.parseUnits("1", DECIMALS));

    balance = await flashloan.connect(accounts[0]).tokenBalance(WETH);
    console.log(`Current balance of WETH = ${balance}`);

  });
  
  });
});

