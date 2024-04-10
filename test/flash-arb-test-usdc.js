const { ethers } = require("hardhat");
const { expect } = require("chai");
const { impersonateFundErc20 } = require("../utils/utilities");


const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const POOL_FEE = 3000; // 0.30% tier
const USDC_WHALE = "0x7713974908be4bed47172370115e8b1219f4a5f0";




describe("UniswapV3Arb", function () {
  
  describe("UniswapV3MultiHopSwap", function () {
    let accounts, BORROW_AMOUNT;
    const initialFundingHuman = "10"; 
    const DECIMALS = 6; //USDC Demicals
    
    beforeEach(async function () {
      accounts = await ethers.getSigners();
      let usdc = await ethers.getContractAt("IERC20", USDC);

      BORROW_AMOUNT = ethers.parseUnits("30", DECIMALS);

      console.log(
        "USDC balance of whale: ",
        await usdc.balanceOf(USDC_WHALE)
      );

      const Flashloan = await ethers.getContractFactory(
        "FlashloanArb"
      );

      flashloan = await Flashloan.deploy();
      await flashloan.waitForDeployment();
      
      console.log('Impersonation Started.')
      await impersonateFundErc20(
        usdc,
        USDC_WHALE,
        flashloan.target,
        initialFundingHuman,
        DECIMALS
      );
      console.log('Impersonation completed.')

    });


  it("ensures contract is funded", async () => {
      const balOfUSDCOnContract = await flashloan.tokenBalance(USDC);

      const flashSwapBalanceHuman = ethers.formatUnits(
        balOfUSDCOnContract,
        DECIMALS
      );
      expect(Number(flashSwapBalanceHuman)).equal(Number(initialFundingHuman));
  });


  it("borrow USDC flash loan", async () => {
    await flashloan.initArbPool(USDC, WETH, POOL_FEE);
    
    console.log(`Borrowing ${BORROW_AMOUNT} USDC`);
    await flashloan.flash(BORROW_AMOUNT, 0);

    balance = await flashloan.tokenBalance(USDC);
    console.log(`Current balance of USDC = ${balance}`);

  });
  
  });
});

