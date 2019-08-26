const secretAdminKey = "fnADWu_uwLACCI7LXiCJ7Szqvqjvk8BFndUFRMvy";

readAuthRecordFromDb = async (tvlistingsClient, tvlistingsQuery, obj) => {
  const userIndex = 'users_by_username';
  if(!obj || !obj.lookupKey) {
    throw('Valid data not passed in');
  }
  let lookupKey = obj.lookupKey;

  try {
    let ret = await tvlistingsClient.query(
      tvlistingsQuery.Get(
        tvlistingsQuery.Match(tvlistingsQuery.Index(userIndex), lookupKey)));
     console.log(ret);
     if (ret && ret.data)  {
       return ret.data;
     } else {throw('can not get data');}

   } catch (e) {
     throw(e);
 }
};

createIfNotExists = async (tvlistingsClient, tvlistingsQuery,collection, obj) => {
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


module.exports = {
  readAuthRecordFromDb,
  createIfNotExists
};
