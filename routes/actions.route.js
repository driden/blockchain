const express = require("express");
const router = express.Router();

const { getContract } = require("../services/contract.service");

router.post("/actions/cancelcontract", async (req, res) => {
  const { myAddress, contractAddress } = req.body;
  const contract = getContract(contractAddress);

  try {
    const result = await contract.methods
      .cancelContract()
      .send({ from: myAddress });
    res.status(200).send({ success: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

router.post("/actions/withdrawfunds", async (req, res) => {
  const { myAddress, contractAddress, reason } = req.body;
  const contract = getContract(contractAddress);

  try {
    const result = await contract.methods
      .withdrawFunds(reason)
      .send({ from: myAddress });
    res.status(200).send({ success: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

router.post("/actions/repayfunds", async (req, res) => {
  const { myAddress, contractAddress } = req.body;
  const contract = getContract(contractAddress);

  try {
    const result = await contract.methods
      .repayFunds()
      .send({ from: myAddress });
    res.status(200).send({ success: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

router.post("/actions/activatecontract", async (req, res) => {
  const { myAddress, contractAddress } = req.body;
  const contract = getContract(contractAddress);

  try {
    const result = await contract.methods
      .activateContract()
      .send({ from: myAddress });
    res.status(200).send({ success: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

router.post("/actions/liquidatecontract", async (req, res) => {
  const { myAddress, contractAddress } = req.body;
  const contract = getContract(contractAddress);

  try {
    const result = await contract.methods
    //   .attemptToLiquidateContract()
      .send({ from: myAddress });
    res.status(200).send({ success: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

router.post("/actions/reduceinheritance", async (req, res) => {
  const { myAddress, contractAddress, amountToReduce } = req.body;
  const contract = getContract(contractAddress);

  try {
    const result = await contract.methods
      .reduceInheritanceAmount(amountToReduce)
      .send({ from: myAddress });
    res.status(200).send({ success: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

module.exports = router;
