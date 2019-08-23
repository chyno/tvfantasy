

console.log('faunadb is ' +faunadb);
const secretKey = "fnADWcLT_fACDXoJvPFkhmgDxMFcEJsM8Xh2gAx-";
//var client = new faunadb.Client({ secret: secretKey });
var q = faunadb.query, client = new faunadb.Client({
    secret: secretKey
   });

export class Fauna {
  constructor() {}

  async createIfNotExists(collection, obj) {
    // Todo: Check is exists
    let response = await client.query(
      q.Create(q.Collection(collection), { data: obj })
    );
    return response.ref;
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
