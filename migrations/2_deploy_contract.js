const Company = artifacts.require('Company');

module.exports = function (deployer) {
  deployer.deploy(Company);
};

