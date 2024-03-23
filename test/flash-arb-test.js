const { ethers } = require("hardhat");
const { expect } = require("chai");
const { impersonateFundErc20 } = require("../utils/utilities");


const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
const POOL_FEE = 3000; // 0.30% tier

const USDC_WHALE = "0x7713974908be4bed47172370115e8b1219f4a5f0";




describe("UniswapV3Arb", function () {
  
  describe("UniswapV3MultiHopSwap", function () {
    let accounts, dai, weth;
    const initialFundingHuman = "100"; 
    const DECIMALS = 6; //USDC Demicals
    

    beforeEach(async function () {
      accounts = await ethers.getSigners();
      let dai = await ethers.getContractAt("IERC20", DAI);
      let weth = await ethers.getContractAt("IWETH", WETH);
      let usdc = await ethers.getContractAt("IERC20", USDC);

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
    balance = await flashloan.connect(accounts[0]).tokenBalance(USDC);
    console.log(`Current balance of USDC = ${balance}`);

    // Execute flashloan to borrow 1000 USDC.
    await flashloan.connect(accounts[0]).initArbPool(WETH, USDC, POOL_FEE);
    // await flashloan.connect(accounts[0]).flash(0, ethers.parseUnits("1", DECIMALS));

    balance = await flashloan.connect(accounts[0]).tokenBalance(USDC);
    console.log(`Current balance of USDC = ${balance}`);

  });
  
  });
});
