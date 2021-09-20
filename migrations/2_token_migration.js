const CrudeToken = artifacts.require("CrudeToken");

module.exports = async function (deployer) {
  await deployer.deploy(CrudeToken, "Crude Crews", "NFTG");
  let tokenInstance = await CrudeToken.deployed();
  console.log(tokenInstance);
  await tokenInstance.addTribe("warrior", 100, 50, 20, 8, 20, 15);
  await tokenInstance.addTribe("rogue", 100, 50, 20, 8, 20, 15);
  await tokenInstance.addTribe("magi", 100, 50, 20, 8, 20, 15);

  await tokenInstance.mint("warrior");
  let crude0 = await tokenInstance.getCrudeDetails(0);
  console.log(crude0);
};
