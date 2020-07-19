const express = require("express");
const router = express.Router();

const { getContract } = require("../services/contract.service");

router.post("/", async (req, res) => {
  const {
    heirAddress,
    heirPercentage,
    heirPayoutOrder,
    myAddress,
    contractAddress,
  } = req.body;

  const contract = getContract(contractAddress);

  try {
    const result = await contract.methods
      .addHeir(heirAddress, heirPercentage, heirPayoutOrder)
      .send({ from: myAddress });
    res.status(200).send({ success: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

router.delete("/:heirAddress", async (req, res) => {
  const managerAddress = req.param("heirAddress");
  const { myAddress, contractAddress } = req.body;

  const contract = getContract(contractAddress);
  try {
    const result = await contract.methods
      .removeHeir(managerAddress)
      .send({ from: myAddress });
    res.status(200).send({ transactionId: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

module.exports = router;
