import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";

task("pair", "Get pair")
  .addParam("address", "The factory address")
  .addParam("tokena", "Token A address")
  .addParam("tokenb", "Token B address")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const contract = await hre.ethers.getContractAt("IUniswapV2Factory", taskArguments.address);

    const pair = await contract.getPair(taskArguments.tokena, taskArguments.tokenb);

    console.log(`Pair: ${pair}`);
  });
