const express = require("express");
const router = express.Router();

const Web3 = require('Web3');

const contractService = require("../services/contract.service");
const ganacheProvider = require("../providers/ganache");

const web3 = new Web3(ganacheProvider);

const response = {
  success: true,
  error: {},
};

const success = () => response;
const error = (msg) => {
  response.success = false;
  response.error = msg;
  return response;
};

router.get("/compile", function (req, res) {
  try {
    contractService.compile();
    res.status(200).send(success());
  } catch (error) {
    res.send(500).send(error("Cannot compile contract"));
  }
});

router.get("/deploy", async function (req, res) {
  try {
    await contractService.deploy();
    res.status(200).send(success());
  } catch (error) {
    res.send(500).send(error("Cannot deploy contract"));
  }
});

router.get("/split", async function (req, res) {
  try {
    const contract = contractService.getContract();
    const accounts = await web3.eth.getAccounts();
    let result = await contract.methods.split().send({
      from: accounts[0],
    });
    res.status(200).send(success());
  } catch (error) {
    res.send(500).send(error("Cannot deploy contract"));
  }
});

module.exports = router;
