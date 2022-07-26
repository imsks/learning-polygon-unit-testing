const Company = artifacts.require('Company');

module.exports = function (deployer, networks, accounts) {
  deployer.deploy(Company, account);
};
