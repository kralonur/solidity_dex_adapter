# Dex Adapter

Adapter for uniswap-v2 based dexes like uniswap and pancakeswap.
The adapter also can be used to get fees using AdapterWithFee contract.
Every time user makes a swap, fee is taken from user.
Fee is set by admin and can be changed.

Notes:
Calculations saved under `calculations.pdf` and `calculations.txt`

The project also has tasks for calculations and pair.

To get pair of 2 tokens:

```bash
yarn pair --address ${IUniswapV2Factory address} --tokena ${first token} --tokenb ${second token} --network ${network}
```

To calculate output amount of tokens: (input token amount is 1 ETH amount of tokens by default)

```bash
yarn calculateoutput --pair ${pair address} --from ${token to sell (input token)} --network rinkeby
```

Note: --from should be either 0 or one 0 is tokena, 1 is tokenb
(This information can be get from UniswapV2Pair pair address, so first get pair address then see tokena and tokenb, 0 is tokena)

To calculate input amount of tokens: (output token amount is 1 ETH amount of tokens by default)

```bash
yarn calculateinput --pair ${pair address} --from ${token to sell (input token)} --network rinkeby
```

## Installation

### Pre Requisites

Before running any command, you need to create a .env file and set a BIP-39 compatible mnemonic as an environment variable. Follow the example in .env.example. If you don't already have a mnemonic, use this [website](https://iancoleman.io/bip39/) to generate one.

1. Install node and npm
2. Install yarn

```bash
npm install --global yarn
```

Check that Yarn is installed by running:

```bash
yarn --version
```

Then, proceed with installing dependencies:

```bash
yarn install
```

## Usage/Examples

### Compile

Compile the smart contracts with Hardhat:

```bash
yarn compile
```

### TypeChain

Compile the smart contracts and generate TypeChain artifacts:

```bash
yarn typechain
```

### Lint Solidity and TypeScript

Lint the Solidity and TypeScript code (then check with prettier):

```bash
yarn lint
```

### Clean

Delete the smart contract artifacts, the coverage reports and the Hardhat cache:

```bash
yarn clean
```

### Available Tasks

To see available tasks from Hardhat:

```bash
npx hardhat
```

## Running Tests

### Test

To run tests, run the following command:

```bash
yarn test
```

### Test with gas reportage

To report gas after test, set `REPORT_GAS="true"` on `.env` file. Then run test.

### Coverage

Generate the code coverage report:

```bash
yarn coverage
```

## Contributing

For git linting [commitlint](https://github.com/conventional-changelog/commitlint) is being used. [This website](https://commitlint.io/) can be helpful to write commit messages.
