# Uniswap v3 Flashloan Trianglugar Arbitrage - Building blocks

To resolve dependencies before running test cases :

```shell
npm install 
```

This project demostrates use cases as below:

* Mainnet forking and impersonation
    * [Mainnet forking configuration in hardhat config file](./hardhat.config.js) ***Please replace with your own Alchemy API key***
    * [Impersonation in two ways](./utils/utilities.js)

* Flashloan (Uniswap v3)
    * [Flashloan contract](./contracts/Flashloan.sol)
    * To run test case `npx hardhat test test/flash-loan-test-usdc.js`

* Multi hop swap (Uniswap v3)
    * [Multi-hop swap](./contracts/MultiHopSwap.sol)
    * To run test case `npx hardhat test test/multihop-swap-test-usdc.js`



