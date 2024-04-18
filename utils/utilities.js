const { network, ethers } = require("hardhat");

const fundErc20 = async (contract, sender, recepient, amount, decimals) => {
  const FUND_AMOUNT = ethers.parseUnits(amount, decimals);
  const whale = await ethers.getSigner(sender);
  const contractSigner = contract.connect(whale);
  await contractSigner.transfer(recepient, FUND_AMOUNT);
};

const impersonateFundErc20 = async (contract, sender, recepient, amount, decimals) => {
  await network.provider.request({
    method: "hardhat_impersonateAccount",
    params: [sender],
  });

  // fund baseToken to the contract
  await fundErc20(contract, sender, recepient, amount, decimals);
  await network.provider.request({
    method: "hardhat_stopImpersonatingAccount",
    params: [sender],
  });
};

const anotherImpersonateFundErc20 = async (contract, sender, recepient, amount, decimals) => {
  const FUND_AMOUNT = ethers.parseUnits(amount, decimals);
  const whaleSigner = await ethers.getImpersonatedSigner(sender);
  await contract.connect(whaleSigner).transfer(recepient, FUND_AMOUNT);
};

module.exports = {
  impersonateFundErc20: impersonateFundErc20,
  anotherImpersonateFundErc20 : anotherImpersonateFundErc20,
  fundErc20: fundErc20
};
