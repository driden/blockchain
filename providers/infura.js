const HDWalletProvider = require("truffle-hdwallet-provider");
const config = require("../config.json");

module.exports = new HDWalletProvider(
  config.infuraMneumonic,
  config.infuraEndpoint,
  0,
  3
);
