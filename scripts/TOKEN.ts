import { ethers } from 'hardhat';

// global scope, and execute the script.

async function main() {
  // const lockedAmount = ethers.parseEther("0.001");

  const tokenFactory = await ethers.getContractFactory('TOKEN');
  const tokenContract = await tokenFactory.deploy(
    'TEST',
    'TST',
    100000000000,
    18
  );
  // await tokenFactory.waitForDeployment();

  console.log(
    'Staking contract is deployed!',
    await tokenContract.getAddress()
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
