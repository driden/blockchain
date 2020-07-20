const path = require("path");
const fs = require("fs");

const Web3 = require("Web3");
const ganacheProvider = require("../providers/ganache");
const infuraProvider = require("../providers/infura");

const web3 = new Web3(infuraProvider);

const COMPILED_FILE_NAME = "Inherit.json";

const resolveCompiledContract = () =>
  path.resolve(process.cwd(), "build", "contracts", COMPILED_FILE_NAME);

const getMetaFiles = () => {
  const contractPath = resolveCompiledContract();
  const { abi, bytecode } = JSON.parse(fs.readFileSync(contractPath, "utf8"));
  return { abi, bytecode };
};

const methods = {
  // compile() {
  //   const contractPath = path.resolve(
  //     process.cwd(),
  //     "build",
  //     "contracts",
  //     SOL_FILE_NAME
  //   );
  //   const compilerInput = {
  //     language: "Solidity",
  //     sources: {
  //       obligatorio: { content: fs.readFileSync(contractPath, "utf8") },
  //     },
  //     settings: {
  //       outputSelection: {
  //         "*": {
  //           "*": ["abi", "evm.bytecode"],
  //         },
  //       },
  //     },
  //   };

  //   const compliedContract = JSON.parse(
  //     solc.compile(JSON.stringify(compilerInput))
  //   );

  //   const contract = compliedContract.contracts["obligatorio"].Inherit;
  //   const abi = contract.abi;
  //   const abiPath = path.resolve(process.cwd(), "contracts", "abi.json");
  //   fs.writeFileSync(abiPath, JSON.stringify(abi, null, 2));

  //   const bytecode = contract.evm;
  //   const bytecodePath = path.resolve(
  //     process.cwd(),
  //     "contracts",
  //     "bytecode.json"
  //   );
  //   fs.writeFileSync(bytecodePath, JSON.stringify(bytecode, null, 2));
  // },

  async deploy(ownerAddress, args) {
    const { abi, bytecode } = getMetaFiles();
    const accounts = await web3.eth.getAccounts();
    console.log(accounts)
    const result = await new web3.eth.Contract(abi)
      .deploy({
        data: bytecode,
        arguments:args,
      })
      .send({
        gas: "300000",
        gasPrice:5,
        // from: ownerAddress,
        from: "0x9dF1967B73e8857F153a6A3d7D9533Bc75Fa4C1D",
        value: web3.utils.toWei("1.5", "ether"),
      });

    return result.options.address;
  },

  getContract(contractAddress) {
    const { abi } = getMetaFiles();
    return new web3.eth.Contract(abi, contractAddress);
  },
};

module.exports = { ...methods };
