var assert = require("assert");
var Web3 = require("web3");
var getDataObj = require("./fakeds");
var utils = require("../js/utils");

const WalletSubprovider = require("ethereumjs-wallet/provider-engine");
const ProviderEngine = require("web3-provider-engine");
const { Hedgehog, WalletManager, Authentication } = require("@audius/hedgehog");
const userName = "foo";
const password = "bar";

const dbObj = getDataObj();
const setAuthFn = async obj => dbObj.createIfNotExists(obj.lookupKey, obj);
const setUserFn = async obj => dbObj.createIfNotExists(obj.username, obj);
const getFn = async obj => dbObj.readRecord(obj);

describe("Can create fake data", function() {
  xit("get function test ", async function() {
    let fdata = {
      foo: {
        username: "foo",
        walletAddress: "0x1f209005dffcfb9b7f956012597bbfa6a9fa54d3"
      },
      "3d68622224c376ff876a2561aba4c5afc2b9b74400e6d136bcb5a0f0a00a1054": {
        iv: "c4cbc2a38a3e2b3c2ae432823d806cea",
        cipherText:
          "3c9a22d9b7fdcc7e429241f8f0a19c7fccd0157a91559d7c98989f37bef943e5de86649bc26d861c7f1ce6178af450987314ca08e3ab577fb42d0ebd03e17935",
        lookupKey:
          "3d68622224c376ff876a2561aba4c5afc2b9b74400e6d136bcb5a0f0a00a1054"
      },
      foo1: {
        username: "foo1",
        walletAddress: "0x9c314a772d0e80c0222b56dbe43432d189cd6cca"
      },
      "932426c36cb447e9bd0524b4307e17371fbada06116208d53ca4ccabecf43d92": {
        iv: "dd7d04c1854c5a65c7abf39d406d2ef7",
        cipherText:
          "142360592fd7230634420c631ceb58697d7af9fa91cac30fe6fad5b9723ee6bdde5baafc101acc0020c520478670c467cfb1e5d111008f396b4713496b46aef3",
        lookupKey:
          "932426c36cb447e9bd0524b4307e17371fbada06116208d53ca4ccabecf43d92"
      }
    };

    dbObj.db = fdata;
    let lookupKey = await WalletManager.createAuthLookupKey(userName, password);
    let data = await getFn({ lookupKey: lookupKey });
    assert.ok(data, "fake data created");

    let lookupKey1 = await WalletManager.createAuthLookupKey(
      userName + "1",
      password + "1"
    );
    let data1 = await getFn({ lookupKey: lookupKey1 });
    assert.ok(data1, "fake data created");
  });
});

describe("web3 and hedgehog", function() {
  let hedgehog = "not set";
  beforeEach(async function() {
    hedgehog = new Hedgehog(getFn, setAuthFn, setUserFn);
  });

  xit("Can create wallet", function() {
    assert.ok(hedgehog, "hedge hog to be defined");
  });

  xit("Can login to hedge hog", async function() {
    assert.ok(wallet, "problem logging into hedge hog");
  });

  xit("Can send ether using hedgehog wallet", async () => {
    const prov = new Web3.providers.HttpProvider("http://localhost:8545");
    const web3 = new Web3(prov);
    const eth = web3.eth;
    let accounts = await eth.getAccounts();
    const wallet = await utils.getNewWallet(
      hedgehog,
      "jchynoweth",
      "password12345"
    );
    const publicKeyAddress = wallet.getAddressString();

    /*
 eth,
  web3,
  fromPrivateKey,
  accountFrom,
  accountTo
     */
    const acct1Privatekey =
      "54d5ee2fc7be63e650fce91aecebdf7cb779b63b389aeb849c60a5cf1ced227e";
    const acc1 = accounts[0];
    const tx = await utils.getSignedTransaction(
      12,
      web3,
      acct1Privatekey,
      acc1,
      publicKeyAddress
    );

    var sTx = tx.serialize().toString("hex");
    console.log(`Transaction id: ${sTx}`);
    //send raw transaction
    
    let tranhash = await web3.eth.sendSignedTransaction(sTx);
    //let ranReceipt  = await web3.eth.getTransactionReceipt(tranhash);

    assert.ok(ranReceipt, "has transaction");
  });

  it("Can send ether from wallet to second account", async () => {
    const prov = new Web3.providers.HttpProvider("http://localhost:8545");
    const web3 = new Web3(prov);
    const eth = web3.eth;
    let accounts = await eth.getAccounts();
    const wallet = await utils.getNewWallet(
      hedgehog,
      "jchynoweth",
      "password12345"
    );
    const walletPublicKey = wallet.getAddressString();
    const workingPK = wallet.getPrivateKeyString();
    const walletPrivateKey = workingPK.substring(2, workingPK.length);
    //   const acct1Privatekey = '54d5ee2fc7be63e650fce91aecebdf7cb779b63b389aeb849c60a5cf1ced227e';
    const toAcc = accounts[1];
    const tx = await utils.getSignedTransaction(
      4,
      web3,
      walletPrivateKey,
      walletPublicKey,
      toAcc
    );

    var sTx = tx.serialize().toString("hex");
    console.log(`Transaction id: ${sTx}`);
    // //send raw transaction
    //  let tranhash = await web3.eth.sendSignedTransaction(sTx);
    //  //let ranReceipt  = await web3.eth.getTransactionReceipt(tranhash);

    //   assert.ok(ranReceipt, "has transaction");
  });
  xit("can get value", async () => {
    const prov = new Web3.providers.HttpProvider("http://localhost:8545");
    const web3 = new Web3(prov);
    const eth = web3.eth;
    let accounts = await eth.getAccounts();
    //console.log(accounts);
    let account = accounts[0];
    let ethBal = await utils.balance(web3, account);
    //  let amount = await web3.eth.getBalance(account);
    console.log(ethBal);
    assert.ok(ethBal === 100, "has amount");
  });

  xit("can send ether from one account to another using my local wallet", async () => {
    const prov = new Web3.providers.HttpProvider("http://localhost:8545");
    const web3 = new Web3(prov);
    const eth = web3.eth;
    let accounts = await eth.getAccounts();

    //get signed transaction & set in a var
    // tx.serialize().toString("hex");
    // var sTx = tx.serialize().toString("hex");

    //send raw transaction
    //  let tranhash = await web3.eth.sendSignedTransaction("0x" + tx.serialize().toString("hex"));
    //  return await web3.eht.getTransactionReceipt(tranhash);
  });

  xit("can transer money to wallet", async () => {
    const prov = new Web3.providers.HttpProvider("http://localhost:8545");
    const web3 = new Web3(prov);

    // web3.eth.defaultAccount = 0xADB057708A954f763e7560227510DBB5b2f42022;
    const eth = web3.eth;
    let accounts = await eth.getAccounts();
    const amountToSend = 0.001;
    //console.log(accounts);
    let account = accounts[0];
    let amount = await balance(web3, account);
    console.log(amount);

    assert.ok(amount > 10000000000000000000, "has amount");
  });
});
