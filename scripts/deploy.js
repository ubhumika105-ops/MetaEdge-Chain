const hre = require("hardhat");

async function main() {
  const Project = await hre.ethers.getContractFactory("DappTorch");
  const project = await Project.deploy();
  await project.waitForDeployment();

  console.log("✅ Project deployed to:", await project.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
