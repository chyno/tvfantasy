const secretAdminKey = "fnADWu_uwLACCI7LXiCJ7Szqvqjvk8BFndUFRMvy";

const readAuthRecordFromDb = async (tvlistingsClient, tvlistingsQuery, obj) => {
                                
  const authenticationsIndex = 'authentications_by_lookupkey';
  
  try {
    let ret = await tvlistingsClient.query(
      tvlistingsQuery.Get(
        tvlistingsQuery.Match(tvlistingsQuery.Index(authenticationsIndex), obj.lookupKey)));
     console.log(ret);
     if (ret && ret.data)  {
       return ret.data;
     }
     return null;

   } catch (e) {
     throw(e);
   }
};

const createIfNotExists = async (tvlistingsClient, tvlistingsQuery,collection, obj) => {
  // Todo: Check is exists

  try {
    let response = await tvlistingsClient.query(
    tvlistingsQuery.Create(tvlistingsQuery.Collection(collection), { data: obj }));
    return response.ref;
  } catch (e) {
      console.log('**** Error :' +e);
      throw e;
  } 
};


export const faunaService = {
readAuthRecordFromDb,
createIfNotExists,
secretAdminKey
};

