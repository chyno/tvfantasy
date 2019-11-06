const faunadb = require('faunadb');
const { Hedgehog, /*WalletManager, Authentication */ } = require('@audius/hedgehog');
const AUTH_COL = "authentications";
const USER_COL = "User";
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


const _getUserIdFromUserName =  (client, query) => {  
  return async (username) => {
    const userNameIndex = 'users_by_username';
    try {
      let ret = await client.query(
        query.Get(
          query.Match(query.Index(userNameIndex), username)));
       console.log(ret);
       if (ret && ret.data && ret.data.userId)  {
         return ret.data.userId;
       }
       return null;
  
     } catch (e) {
       throw(e);
     }
  };
};

/*
client.query(
  q.Get(q.Ref(q.Collection('posts'), '192903209792046592'))
)


client.query(
  q.Update(
    q.Ref(q.Collection('posts'), '192903209792046592'),
    { data: { tags: ['pet', 'cute'] } },
  )
)
*/
const _setId =  (client, query) => {  
  return async (username, id) => {
    const userNameIndex = 'users_by_username';
    try {
      console.log("******************************************");
      console.log("Adding " + id);
      let ret = await client.query(
        query.Update(
          query.Match(query.Index(userNameIndex), username),
          {data: {id: id}}
          ));
          console.log("******************************************");
       console.log(ret);
       if (ret && ret.data)  {
         return ret;
       }
       return null;
  
     } catch (e) {
       throw(e);
     }
  };
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
const setAuthFn = async obj =>
    createIfNotExists(client, q, AUTH_COL, obj);
const setUserFn = async obj =>
    createIfNotExists(client, q, USER_COL, obj);
const getFn = async obj => readAuthRecordFromDb(client, q, obj); 


function LoginService() {
   //this.hedgehog  = new Hedgehog(getFn, setAuthFn, setUserFn);
}

LoginService.prototype.hedgehog = new Hedgehog(getFn, setAuthFn, setUserFn);

LoginService.prototype.getUserIdFromUserName = _getUserIdFromUserName(client, q);
LoginService.prototype.setId = _setId(client, q);
module.exports = LoginService;
//export const hedgehog = new Hedgehog(getFn, setAuthFn, setUserFn);
