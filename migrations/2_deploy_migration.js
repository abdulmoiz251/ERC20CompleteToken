var Token = artifacts.require("AMToken.sol");

module.exports = function(deployer) {
  deployer.deploy(Token);
};
