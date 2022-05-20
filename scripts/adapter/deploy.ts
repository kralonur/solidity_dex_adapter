import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import fs from "fs-extra";
import { ethers } from "hardhat";
import { Adapter__factory } from "../../src/types";

async function main() {
  const [owner] = await ethers.getSigners();
  const args = getContractArgs();
  const contract = await getContract(owner, args);
  console.log("Refund deployed to: ", contract.address);
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});

async function getContract(owner: SignerWithAddress, args: any[]) {
  const factory = new Adapter__factory(owner);
  const contract = await factory.deploy(args[0]);
  await contract.deployed();

  return contract;
}

function getContractArgs() {
  const json = fs.readJSONSync("./deployargs/deployAdapterArgs.json");

  const router = String(json.router);

  return getContractArgsArray(router);
}

function getContractArgsArray(router: string) {
  return [router];
}
