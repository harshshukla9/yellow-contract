import { buildModule } from "@nomicfoundation/hardhat-ignition";

const FactoryV2Module = buildModule("FactoryV2Module", (m) => {
  const factoryV2 = m.contract("FactoryV2");
  const battle = m.contract("MemedBattle", [factoryV2]);

  m.call(factoryV2, "setBattleContract", [battle]);

  return { factoryV2, battle };
});

export default FactoryV2Module; 