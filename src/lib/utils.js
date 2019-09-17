const GasLimit = 21000;
const GasPrice = 20000000000;
var EthTx = require("ethereumjs-tx");

var getExisintWallet = async (hedgehog, username, password) => {
  let wallet;
  
  if (!hedgehog.isLoggedIn()) { 
    wallet = await hedgehog.login(userName, password);
  }
  //await hedgehog.signUp(userName + "1", password + "1");
  if (!wallet) {
    wallet = hedgehog.getWallet();
  }
  return wallet;
};

var getNewWallet = async (hedgehog, userName, password) => {
  let wallet;
  wallet = await hedgehog.signUp(userName, password);

  // if (!hedgehog.isLoggedIn()) { 
  //   wallet = await hedgehog.login(userName, password);
  // }
  // //await hedgehog.signUp(userName + "1", password + "1");
  // if (!wallet) {
  //   wallet = hedgehog.getWallet();
  // }
  return wallet;
};

var getBalance = async (web3, acct) => {
  let bal = await web3.eth.getBalance(acct);
  let res = web3.utils.fromWei(bal, "ether");
  return parseInt(res);
  //return web3.fromWei(web3.eth.getBalance(acct),'ether').toNumber();};
};

sendEth = (web3, frmAcc, toAcc, eth) => {
  const weiAmount = web3.utils.toWei(eth.toString(), "ether");
  return web3.eth.sendTransaction({
    from: frmAcc,
    to: toAcc,
    value: weiAmount,
    gasLimit: GasLimit,
    gasPrice: GasPrice
  });
};
// Callback function has error then data passed in (error, data) => ...
getSignedTransaction = async (
  eth,
  web3,
  fromPrivateKey,
  accountFrom,
  accountTo
) => {
  const fromTranCount = await web3.eth.getTransactionCount(accountFrom);
  const hxTranCount = web3.utils.toHex(fromTranCount);
  const weiAmount = web3.utils.toWei(eth.toString(), "ether");
  var pk1x = new Buffer(fromPrivateKey, "hex");
  //setup transaction data
  var rawTx = {
    nonce: hxTranCount,
    to: accountTo,
    gasPrice: web3.utils.toHex(GasPrice),
    gasLimit: web3.utils.toHex(GasLimit),
    value: web3.utils.toHex(weiAmount),
    data: ""
  };

  //create new tx
  var tx = new EthTx(rawTx);
  //sign
  tx.sign(pk1x);
  return tx;
  //get signed transaction & set in a var
  // tx.serialize().toString("hex");
  // var sTx = tx.serialize().toString("hex");

  //send raw transaction
 //  let tranhash = await web3.eth.sendSignedTransaction("0x" + tx.serialize().toString("hex"));
 //  return await web3.eht.getTransactionReceipt(tranhash);
  
};

module.exports = {
  getBalance,
  sendEth,
  getSignedTransaction,
  getNewWallet
};
