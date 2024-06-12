import { ethers } from "hardhat";

// global scope, and execute the script.

async function main() {
  // const lockedAmount = ethers.parseEther("0.001");
  const routerAddress = "0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008";
  const tokenContract = await ethers.deployContract("TOKEN", [
    "TEST",
    "TST",
    100000000000,
    18,
    routerAddress,
  ]);
  await tokenContract.waitForDeployment();

  console.log(
    "Staking contract is deployed!",
    await tokenContract.getAddress()
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
