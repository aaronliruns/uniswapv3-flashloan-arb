const { ethers } = require("hardhat");


async function main() {
  const WETH_ADDRESS = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
  const USDC_ADDRESS = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
  const POOL_FEE = 3000; // 0.30% tier

  // Need this to convert ETH into WETH (Wrapped Ether) to cover the fees
  const weth = await ethers.getContractAt("IWETH9", WETH_ADDRESS);


  // const flashloan = await ethers.deployContract("Flashloan", [USDC_ADDRESS,WETH_ADDRESS,POOL_FEE]);

  // await flashloan.waitForDeployment();

  [owner, signer2, signer3] = await ethers.getSigners();
  //Owner of contract is the deployer
  Flashloan = await ethers.getContractFactory('Flashloan', owner);
  flashloan = await Flashloan.deploy();
  await flashloan.waitForDeployment();

  console.log(`flashloan address= ${flashloan.target}`);

  await flashloan.connect(owner).initArbPool(USDC_ADDRESS, WETH_ADDRESS, POOL_FEE);

  // Get some WETH to cover fee and approve Flashloan contract to use it.
  // Fee: 1 ETH * 0.3% = 0.003 ETH
  await weth.approve(flashloan.target, ethers.parseEther("0.003"));
  // Deposit ether to get wrapped ether
  await weth.deposit({ value: ethers.parseEther("0.003") });

  balance = await flashloan.connect(owner).wethBalance();
  console.log(`Current balance of WETH = ${balance}`);


  // Execute flashloan to borrow 1 ETH.
  await flashloan.connect(owner).flash(0, ethers.parseEther("1"));

  balance = await flashloan.connect(owner).wethBalance();
  console.log(`Current balance of WETH = ${balance}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
