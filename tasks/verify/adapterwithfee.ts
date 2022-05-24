import fs from "fs-extra";
import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";

task("verify:adapterwithfee", "Verifies the AdapterWithFee contract")
  .addParam("address", "The contract address")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const json = fs.readJSONSync("./deployargs/deployAdapterWithFeeArgs.json");
    const router = String(json.router);

    await hre.run("verify:verify", {
      address: taskArguments.address,
      constructorArguments: [router],
    });
  });
