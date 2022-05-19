import fs from "fs-extra";
import { task } from "hardhat/config";
import { TaskArguments } from "hardhat/types";

task("verify:adapter", "Verifies the Adapter contract")
  .addParam("address", "The contract address")
  .setAction(async function (taskArguments: TaskArguments, hre) {
    const json = fs.readJSONSync("./deployargs/deployAdapterArgs.json");
    const factory = String(json.factory);
    const router = String(json.router);

    await hre.run("verify:verify", {
      address: taskArguments.address,
      constructorArguments: [factory, router],
    });
  });
