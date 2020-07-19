const path = require("path");
const fs = require("fs");
const solc = require("solc");

const Web3 = require("Web3");
const ganacheProvider = require("../providers/ganache");

const web3 = new Web3(ganacheProvider);

const methods = {
  compile() {
    const contractPath = path.resolve(
      process.cwd(),
      "contracts",
      "obligatorio.sol"
    );
    const compilerInput = {
      language: "Solidity",
      sources: {
        obligatorio: { content: fs.readFileSync(contractPath, "utf8") },
      },
      settings: {
        outputSelection: {
          "*": {
            "*": ["abi", "evm.bytecode"],
          },
        },
      },
    };

    const compliedContract = JSON.parse(
      solc.compile(JSON.stringify(compilerInput))
    );

    const contract = compliedContract.contracts["obligatorio"].Inherit;
    const abi = contract.abi;
    const abiPath = path.resolve(process.cwd(), "contracts", "abi.json");
    fs.writeFileSync(abiPath, JSON.stringify(abi, null, 2));

    const bytecode = contract.evm;
    const bytecodePath = path.resolve(
      process.cwd(),
      "contracts",
      "bytecode.json"
    );
    fs.writeFileSync(bytecodePath, JSON.stringify(bytecode, null, 2));
  },

  async deploy() {
    const bytecodePath = path.resolve(
      process.cwd(),
      "contracts",
      "bytecode.json"
    );
    const abiPath = path.resolve(process.cwd(), "contracts", "abi.json");
    const configPath = path.resolve(process.cwd(), "config.json");

    const bytecode = JSON.parse(fs.readFileSync(bytecodePath, "utf8")).bytecode;
    const abi = JSON.parse(fs.readFileSync(abiPath, "utf8"));

    const accounts = await web3.eth.getAccounts();

    const result = await new web3.eth.Contract(abi)
      .deploy({
        data: "0x" + bytecode.object,
        arguments: [],
      })
      .send({
        gas: "3000000",
        from: accounts[0],
        value: web3.utils.toWei("10", "ether"),
      });

    const config = JSON.parse(fs.readFileSync(configPath, "utf8"));
    config.contractAddress = result.options.address;
    fs.writeFileSync(configPath, JSON.stringify(config, null, 2));
  },

  getContract(contractAddress) {
    const abiPath = path.resolve(process.cwd(), "build","contracts", "Inherit.json");
    const abi = JSON.parse(fs.readFileSync(abiPath, "utf8")).abi;    
    return new web3.eth.Contract(abi, contractAddress);
  },
};

module.exports = { ...methods };
