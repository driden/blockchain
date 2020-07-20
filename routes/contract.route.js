const express = require("express");
const router = express.Router();

const Web3 = require("Web3");
 
constcontractService = require("../services/contract.service");
const ganacheProvider = require("../providers/ganache");
const infuraProvider = require("../providers/infura");

const web3 = new Web3(infuraProvider);

const response = {
  success: true,
  error: {},
  result: {},
};

const success = (result) => {
  response.result = result;
  return response;
};
const errorMsg = (msg) => {
  response.success = false;
  response.error = msg;
  return response;
};

// Usamos truffle
router.get("/compile", function (req, res) {
  try {
    contractService.compile();
    res.status(200).send(success());
  } catch (error) {
    res.send(500).send(errorMsg("Cannot compile contract"));
  }
});

router.post("/deploy/inherit", async function (req, res) {
  try {
    const {
      myAddress,
      ci,
      birthDate,
      hireDate,
      addressP,
      phoneNumber,
      email,
      cancellationPercentage,
      reductionPercentageFee,
      managersPercentangeFee,
      withdrawalPercentageAllowed,
      companyAddress,
      rulesAddress
           
    } = req.body;

    const birthDateStamp = new Date(birthDate);
    const hireDateStamp = new Date(hireDate);

    const contractArgs = [
      ci,
      birthDateStamp.getTime() / 1000,
      addressP,
      phoneNumber,
      email,
      hireDateStamp.getTime() / 1000,
      cancellationPercentage,
      reductionPercentageFee,
      managersPercentangeFee,
      withdrawalPercentageAllowed,
      companyAddress,
      rulesAddress
    ];

    const contractAddress = await contractService.deploy(myAddress,contractArgs);
    res.status(200).send({ deployedAt: contractAddress });
  } catch (error) {
    console.log(error);
    res.status(500).send(errorMsg(error.message));
  }
});

router.post("/deploy/rules", async function (req, res) {
  try {
    const {
      myAddress,
      percentageFee,
      dollarToWeiRate,
      withdrawalPercentageFee,
      withdrawalPenaltyPercentageFeeByDay,
      withdrawalPenaltyMaxDays,
      charityAddress
    } = req.body;

    const contractArgs = [
        percentageFee,
        dollarToWeiRate,
        withdrawalPercentageFee,
        withdrawalPenaltyPercentageFeeByDay,
        withdrawalPenaltyMaxDays,
        charityAddress
    ];

    const contractAddress = await contractService.deploy(myAddress,contractArgs);
    res.status(200).send({ deployedAt: contractAddress });
  } catch (error) {
    res.status(500).send(errorMsg(error.message));
  }
});
module.exports = router;
