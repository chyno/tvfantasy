const faunadb = require('faunadb');
const { Hedgehog, /*WalletManager, Authentication */ } = require('@audius/hedgehog');
const AUTH_COL = "authentications";
const USER_COL = "users";
const faunaKey = "fnADWu_uwLACCI7LXiCJ7Szqvqjvk8BFndUFRMvy";

const readAuthRecordFromDb = async (client, query, obj) => {
                                
    const authenticationsIndex = 'authentications_by_lookupkey';
    
    try {
      let ret = await client.query(
        query.Get(
          query.Match(query.Index(authenticationsIndex), obj.lookupKey)));
       console.log(ret);
       if (ret && ret.data)  {
         return ret.data;
       }
       return null;
  
     } catch (e) {
       throw(e);
     }
};
  
const createIfNotExists = async (client, query,collection, obj) => {
    // Todo: Check is exists
  
    try {
      let response = await client.query(
      query.Create(query.Collection(collection), { data: obj }));
      return response.ref;
    } catch (e) {
        console.log('**** Error :' +e);
        throw e;
    } 
};

const client = new faunadb.Client({ secret: faunaKey });
const q = faunadb.query;
const setAuthFn = async o\bj =>
    createIfNotExists(client, q, AUTH_COL, obj);
const setUserFn = async obj =>
    createIfNotExists(client, q, USER_COL, obj);
const getFn = async obj => readAuthRecordFromDb(client, q, obj); 

function LoginService() {
   //this.hedgehog  = new Hedgehog(getFn, setAuthFn, setUserFn);
}

LoginService.prototype.hedgehog = new Hedgehog(getFn, setAuthFn, setUserFn);



module.exports = LoginService;
//export const hedgehog = new Hedgehog(getFn, setAuthFn, setUserFn);
