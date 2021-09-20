const CrudeToken = artifacts.require("CrudeToken");

module.exports = async function (deployer) {
  await deployer.deploy(CrudeToken, "Crude Crews", "NFTG");
  let tokenInstance = await CrudeToken.deployed();
  console.log(tokenInstance);
  await tokenInstance.addTribe("urban", 100, 50, 20, 8, 20, 15);
  await tokenInstance.addTribe("cyber", 100, 50, 20, 8, 20, 15);
  await tokenInstance.addTribe("brutus", 100, 50, 20, 8, 20, 15);

  await tokenInstance.mint("brutus");
  let crude0 = await tokenInstance.getTokenDetails(0);
  console.log(crude0);
};
