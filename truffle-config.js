module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "5777",
      gas: 5000000
    }
  },
  compilers: {
    solc: {
      version: "^0.5.1", // A version or constraint - Ex. "^0.5.0"
                         // Can also be set to "native" to use a native solc
      parser: "solcjs",  // Leverages solc-js purely for speedy parsing
      settings: {
        optimizer: {
          enabled: true
        }
      }
    }
  }
};