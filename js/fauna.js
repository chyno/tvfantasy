

console.log('faunadb is ' +faunadb);
const secretAdminKey = "fnADWgJgt8ACDfD3rbUmyhnhTuPY425nDHQ9GZ9Y";
const secretClientKey = 'fnADWgKmE-ACCNt8DvTuqmsjsRC71C3AcoGbPJ7x';
//var client = new faunadb.Client({ secret: secretKey });
var q = faunadb.query, client = new faunadb.Client({
    secret: secretAdminKey
   });

export class Fauna {
  constructor() {}

  async createIfNotExists(collection, obj) {
    // Todo: Check is exists
    
    try {
    let response = await client.query(
      q.Create(q.Collection(collection), { data: obj })
    );
    return response.ref;
    } catch (e) {
        console.log('**** Error :' +e);
        throw e;
    }
    
  }

  async readAuthRecordFromDb(obj) {
    let lookupKey = obj.lookupKey;
    var response = await client.query(
      q.Create(q.Collection("authentications"), {
        data: { testField: lookupKey }
      })
    );
    return response.data;
  }
}
