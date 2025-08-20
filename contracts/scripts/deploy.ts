import { ethers } from "hardhat";

async function main() {
  console.log("Deploying contracts to Yellow Network...");

  // Deploy YellowMemedFactory first
  const YellowMemedFactory = await ethers.getContractFactory("YellowMemedFactory");
  const yellowFactory = await YellowMemedFactory.deploy();
  await yellowFactory.waitForDeployment();
  const yellowFactoryAddress = await yellowFactory.getAddress();
  console.log("YellowMemedFactory deployed to:", yellowFactoryAddress);

  // Deploy YellowMemedBattle with factory address
  const YellowMemedBattle = await ethers.getContractFactory("YellowMemedBattle");
  const yellowBattle = await YellowMemedBattle.deploy(yellowFactoryAddress);
  await yellowBattle.waitForDeployment();
  const yellowBattleAddress = await yellowBattle.getAddress();
  console.log("YellowMemedBattle deployed to:", yellowBattleAddress);

  console.log("\nDeployment Summary:");
  console.log("==================");
  console.log("YellowMemedFactory:", yellowFactoryAddress);
  console.log("YellowMemedBattle:", yellowBattleAddress);
  console.log("\nPlease update your frontend/backend with these new contract addresses.");
  console.log("Also update the DEX addresses in YellowMemedFactory.sol with actual Yellow Network DEX addresses.");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  }); 