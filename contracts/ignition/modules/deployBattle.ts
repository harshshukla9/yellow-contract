import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const YellowBattleModule = buildModule("YellowBattleModule", (m) => {
  const YELLOW_FACTORY_ADDRESS = "0x0000000000000000000000000000000000000000"; // TODO: Replace with deployed Yellow Factory address
  
  const yellowBattle = m.contract("YellowMemedBattle", [YELLOW_FACTORY_ADDRESS]);

  return {
    yellowBattle,
  };
});

export default YellowBattleModule;