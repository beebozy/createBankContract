import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";



const BankModule = buildModule("BankModule", (m) => {
  

  const lock = m.contract("Bank");

  return { lock };
});

export default BankModule;
