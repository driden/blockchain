const path = require("path");
const fs = require("fs");

const Web3 = require("Web3");
const ganacheProvider = require("../providers/ganache");
const infuraProvider = require("../providers/infura");

const web3 = new Web3(ganacheProvider);

const COMPILED_INHERIT_NAME = "Inherit.json";
const COMPILED_RULES_NAME = "Rules.json";

const resolveCompiledContract = (contractName) =>
  path.resolve(process.cwd(), "build", "contracts", contractName);

const getMetaFiles = (contractName) => {
  const contractPath = resolveCompiledContract(contractName);
  const { abi, bytecode } = JSON.parse(fs.readFileSync(contractPath, "utf8"));
  return { abi, bytecode };
};

const methods = {
  async deploy(ownerAddress, args) {
    const { abi, bytecode } = getMetaFiles(COMPILED_INHERIT_NAME);
    const result = await new web3.eth.Contract(abi)
      .deploy({
        data: bytecode,
        arguments:args,
      })
      .send({
        gas: "300000",
        from: ownerAddress,
        value: web3.utils.toWei("1.8", "ether"),
      });

    return result.options.address;
  },
  async deployRulesContract(ownerAddress, args) {
    const { abi, bytecode } = getMetaFiles(COMPILED_RULES_NAME);
    const result = await new web3.eth.Contract(abi)
      .deploy({
        data: bytecode,
        arguments:args,
      })
      .send({
        from: ownerAddress,
      });

    return result.options.address;
  },

  getContract(contractAddress) {
    const { abi } = getMetaFiles();
    return new web3.eth.Contract(abi, contractAddress);
  },
};

module.exports = { ...methods };
