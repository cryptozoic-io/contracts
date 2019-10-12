
var HDWalletProvider = require("truffle-hdwallet-provider");

//
var mnemonic = ""; 
module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*", // Match any network id
      gasPrice:4000000000
    },
    rinkeby: {
	  provider: function() {
		return  new HDWalletProvider(mnemonic, "http://192.168.1.30:8545");
       },
   	  network_id: '*',
   	  gasPrice:40000000000
    }
  },
  solc: {
	 optimizer: {
	   enabled: true,
	   runs: 50
	 }
  } 
};
