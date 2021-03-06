const express = require("express");
const router = express.Router();

const { getContract } = require("../services/contract.service");

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

router.delete("/:managerAddress", async (req, res) => {
  const managerAddress = req.param("managerAddress");
  const { myAddress, contractAddress } = req.body;
  
  const contract = getContract(contractAddress);
  try {
    const result = await contract.methods
      .removeManager(managerAddress)
      .send({ from: myAddress });
    res.status(200).send({ transactionId: result });
  } catch (error) {
    res.status(400).send({ error: error.message });
  }
});

module.exports = router;
