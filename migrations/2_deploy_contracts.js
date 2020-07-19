const inherit = artifacts.require("Inherit");

module.exports = function (deployer) {
  deployer.deploy(inherit, { value: 4242802476308100 * 205, gas:3000000});
};
