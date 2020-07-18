const Web3 = require("web3");

const config = require('../config.json');

module.exports = new Web3.providers.HttpProvider(config.ganacheUrl);