import { BigNumber } from "ethers";
import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";

task("calculateoutput", "Get pair")
  .addParam("pair", "Token A address")
  .addParam("from", "Swap from")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const contract = await hre.ethers.getContractAt("IUniswapV2Pair", taskArguments.pair);

    const reserves = await contract.getReserves();

    const reserveInputInitial = taskArguments.from == 0 ? reserves.reserve0 : reserves.reserve1;

    const reserveOutputInitial = taskArguments.from == 0 ? reserves.reserve1 : reserves.reserve0;

    console.log(String(reserveInputInitial));
    console.log(String(reserveOutputInitial));

    const eth = BigNumber.from("1000000000000000000");
    const fee = BigNumber.from("3000000000000000"); //%0.3 - 0.003
    const contractFee = BigNumber.from("50000000000000000"); //%5 - 0.05
    const multiplier = eth.sub(fee);
    const contractFeeMultiplier = eth.sub(contractFee);
    const amount = eth.mul(1);
    const amountWithFee = amount.mul(contractFeeMultiplier).div(eth).mul(multiplier).div(eth);
    const constantProduct = reserveInputInitial.mul(reserveOutputInitial);
    const reserveOutputAfterExecution = constantProduct.div(reserveInputInitial.add(amountWithFee));
    const amountOut = reserveOutputInitial.sub(reserveOutputAfterExecution);
    const marketPrice = amountWithFee.mul(eth).div(amountOut); //in uniswap it's calculated without fee!
    const midPrice = reserveInputInitial.mul(eth).div(reserveOutputInitial);
    const priceImpact = eth.sub(midPrice.mul(eth).div(marketPrice));

    console.log(`amount: ${amount}`);
    console.log(`amountWithFee: ${amountWithFee}`);
    console.log(`constantProduct: ${constantProduct}`);
    console.log(`reserveOutputAfterExecution: ${reserveOutputAfterExecution}`);
    console.log(`amountOut: ${amountOut}`);
    console.log(`marketPrice: ${marketPrice}`);
    console.log(`midPrice: ${midPrice}`);
    console.log(`priceImpact: ${priceImpact}`);
  });

task("calculateinput", "Get pair")
  .addParam("pair", "Token A address")
  .addParam("from", "Swap from")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const contract = await hre.ethers.getContractAt("IUniswapV2Pair", taskArguments.pair);

    const reserves = await contract.getReserves();

    const reserveInputInitial = taskArguments.from == 0 ? reserves.reserve0 : reserves.reserve1;

    const reserveOutputInitial = taskArguments.from == 0 ? reserves.reserve1 : reserves.reserve0;

    console.log(String(reserveInputInitial));
    console.log(String(reserveOutputInitial));

    const eth = BigNumber.from("1000000000000000000");
    const fee = BigNumber.from("3000000000000000");
    const contractFee = BigNumber.from("50000000000000000"); //%5 - 0.05
    const amountOut = eth.mul(1);
    const amountWithFee = amountOut
      .mul(eth)
      .mul(reserveInputInitial)
      .div(amountOut.sub(reserveOutputInitial).mul(fee.sub(eth)));
    const amountWithFeeToShow = amountWithFee.mul(eth.add(contractFee)).div(eth);
    const constantProduct = reserveInputInitial.mul(reserveOutputInitial);
    const reserveOutputAfterExecution = constantProduct.div(reserveInputInitial.add(amountWithFee));
    const marketPrice = amountWithFee.mul(eth).div(amountOut); //in uniswap it's calculated without fee!
    const midPrice = reserveInputInitial.mul(eth).div(reserveOutputInitial);
    const priceImpact = eth.sub(midPrice.mul(eth).div(marketPrice));

    console.log(`amountWithFee: ${amountWithFee}`);
    console.log(`amountWithFeeToShow: ${amountWithFeeToShow}`);
    console.log(`constantProduct: ${constantProduct}`);
    console.log(`reserveOutputAfterExecution: ${reserveOutputAfterExecution}`);
    console.log(`amountOut: ${amountOut}`);
    console.log(`marketPrice: ${marketPrice}`);
    console.log(`midPrice: ${midPrice}`);
    console.log(`priceImpact: ${priceImpact}`);
  });
