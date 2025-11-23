const { ethers } = require("hardhat");

async function main() {
  const GasLessTrade = await ethers.getContractFactory("GasLessTrade");
  const gasLessTrade = await GasLessTrade.deploy();

  await gasLessTrade.deployed();

  console.log("GasLessTrade contract deployed to:", gasLessTrade.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
