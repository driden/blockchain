const express = require("express");
const router = express.Router();

const Web3 = require("Web3");

const ganacheProvider = require("../providers/ganache");
const { getContract } = require("../services/contract.service");
const web3 = new Web3(ganacheProvider);

router.post("/", async (req, res) => {
  const { managerAddress, myAddress, contractAddress } = req.body;
  const contract = getContract(contractAddress);

  try {
    const result = await contract.methods
      .addManager(managerAddress)
      .send({ from: myAddress });
    res.status(200).send({ success: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

module.exports = router;
