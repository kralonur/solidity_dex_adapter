import { BigNumber } from "ethers";
import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";

task("calculate", "Get pair")
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

    const fee = BigNumber.from("2000000000000000");
    const multiplier = eth.sub(fee);
    const amount = eth.mul(100);
    const amountWithFee = amount.mul(multiplier).div(eth);
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
