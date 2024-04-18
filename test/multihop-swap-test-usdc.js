const { ethers } = require("hardhat");
const { expect } = require("chai");
const { anotherImpersonateFundErc20 } = require("../utils/utilities");


const USDC = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const USDC_WHALE = "0x7713974908be4bed47172370115e8b1219f4a5f0";


describe("UniswapV3MultihopSwap", function () {
  
  describe("UniswapV3MultihopSwapOnly", function () {
    let accounts, receipt;
    const initialFundingHuman = "100";
    const DECIMALS = 6; //USDC Demicals
    
    beforeEach(async function () {
      accounts = await ethers.getSigners();
      let usdc = await ethers.getContractAt("IERC20", USDC);

      console.log(
        "USDC balance of whale: ",
        await usdc.balanceOf(USDC_WHALE)
      );

      const Swap = await ethers.getContractFactory(
        "MultiHopSwap"
      );

      swap = await Swap.deploy();
      await swap.waitForDeployment();
      
      console.log('Impersonation Started.')
      await anotherImpersonateFundErc20(
        usdc,
        USDC_WHALE,
        swap.target,
        initialFundingHuman,
        DECIMALS
      );
      console.log('Impersonation completed.')

    });


  it("ensures contract is funded", async () => {
      const balOfUSDCOnContract = await swap.tokenBalance(USDC);

      const swapBalanceHuman = ethers.formatUnits(
        balOfUSDCOnContract,
        DECIMALS
      );
      expect(Number(swapBalanceHuman)).equal(Number(initialFundingHuman));
  });

  it("performs multi hop swap", async () => {
    balance = await swap.tokenBalance(USDC);
    console.log(`Current balance of USDC = ${balance}`);
    console.log(`Swapping ${initialFundingHuman} USDC`);
    const tx = await swap.swapExactInputMultiHop(ethers.parseUnits(initialFundingHuman, DECIMALS));
    receipt = await tx.wait();
    balance = await swap.tokenBalance(USDC);
    console.log(`Current balance of USDC = ${balance}`);
    expect(balance).not.equal(0);
  });


  it("Get Gas in USD", async () => {
    const gasPrice = receipt.gasPrice;
    const gasUsed = receipt.gasUsed;
    const gasUsedETH = gasPrice * gasUsed;
    console.log(
      "Total Gas USD: " +
        ethers.formatEther(gasUsedETH.toString()) * 3507 // exchange rate today
    );
    expect(gasUsedETH).not.equal(0);
  });
  
  });
});

