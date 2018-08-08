var Migrations = artifacts.require("./Migrations.sol");
var Kurecoin = artifacts.require("./Kurecoin.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(Kurecoin);
};
