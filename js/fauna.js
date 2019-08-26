const secretAdminKey = "fnADWu_uwLACCI7LXiCJ7Szqvqjvk8BFndUFRMvy";

readAuthRecordFromDb = async (tvlistingsClient, tvlistingsQuery, obj) => {
                                
  const authenticationsIndex = 'authentications_by_lookupkey';
  
  try {
    let ret = await tvlistingsClient.query(
      tvlistingsQuery.Get(
        tvlistingsQuery.Match(tvlistingsQuery.Index(authenticationsIndex), obj.lookupKey)));
     console.log(ret);
     if (ret && ret.data)  {
       return ret.data;
     }

   } catch (e) {
     throw(e);
   }
adAuthRecordFromDb,
  createIfNotExists
};
