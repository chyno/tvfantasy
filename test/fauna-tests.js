var assert = require("assert");
var faunadb = require("faunadb"),
  q = faunadb.query;
const userIndex = "users_by_username";
const authenticationsIndex = "authentications_by_lookupkey";

const secretAdminKey = "fnADWu_uwLACCI7LXiCJ7Szqvqjvk8BFndUFRMvy";
// const secretClientKey = 'fnADWgKmE-ACCNt8DvTuqmsjsRC71C3AcoGbPJ7x';
//var client = new faunadb.Client({ secret: 'YOUR_FAUNADB_SECRET' });

var fauna = require("../js/faunadb.js/index.js");

xdescribe("Raw testing of Fauna Javascript API", function() {
  let client = null;

  beforeEach(async function() {
    client = new faunadb.Client({ secret: secretAdminKey });
  });

  xit("Can create client", function() {
    assert.ok(client, "fauna client created");
  });

  xit("Can Create an index on the authorization’s username:", async function() {
    let item = q.CreateIndex({
      name: authenticationsIndex,
      source: q.Collection("authentications"),
      terms: [{ field: ["data", "lookupKey"] }]
    });
    try {
      let ret = await client.query(item);
      console.log(ret);
    } catch (e) {
      const resp = e.requestResult.responseRaw;
      console.log(resp);
      assert.fail(e, resp);
    }
    //.then((ret) => console.log(ret)
  });

  xit("Can Create an index on the users’s username:", async function() {
    let item = q.CreateIndex({
      name: userIndex,
      source: q.Collection("users"),
      terms: [{ field: ["data", "username"] }]
    });
    try {
      let ret = await client.query(item);
      console.log(ret);
    } catch (e) {
      const resp = e.requestResult.responseRaw;
      console.log(resp);
      assert.fail(e, resp);
    }
    //.then((ret) => console.log(ret)
  });

  xit("can add record", async function() {
    let item = q.Create(q.Collection("users"), {
      data: { username: "myusername", foo: "bar" }
    });

    assert(item);
    try {
      let ret = await client.query(item);
      console.log(ret);
      assert(ret);
    } catch (e) {
      const resp = e.requestResult.responseRaw;
      console.log(resp);
      assert.fail(e, resp);
    }
  });

  xit("can get user record by id ", async function() {
    // assert(item);
    try {
      let ret = await client.query(
        q.Get(q.Ref(q.Collection("users"), "241771288921637384"))
      );

      //.then((ret) => console.log(ret));
      console.log(ret);
      assert(ret);

      // get data
      let data = ret.data;
      console.log(data);
      assert(data);

      // get data
      let username = data.username;
      console.log(username);
      assert(username);
    } catch (e) {
      const resp = e.requestResult.responseRaw;
      console.log(resp);
      assert.fail(e, resp);
    }
  });

  xit("can get user record by username ", async function() {
    const userName = "myusername";
    // assert(item);
    try {
      let ret = await client.query(
        q.Get(q.Match(q.Index(userIndex), userName))
      );
      // .then((ret) => console.log(ret))

      //.then((ret) => console.log(ret));
      console.log(ret);
      assert(ret);

      // get data
      let data = ret.data;
      console.log(data);
      assert(data);

      // get data
      let username = data.username;
      console.log(username);
      assert(username);
    } catch (e) {
      const resp = e.requestResult.responseRaw;
      console.log(resp);
      assert.fail(e, resp);
    }
  });
});

describe("Test Fauna Service", function() {
  let client = null;

  beforeEach(async function() {
    this.client = new faunadb.Client({ secret: secretAdminKey });
  });

  xit("fauna class exports functions", function() {
    let fn = fauna.readAuthRecordFromDb;
    assert.ok(fn, "fauna function created");

    let fn2 = fauna.createIfNotExists;
    assert.ok(fn2, "fauna function created");
  });

  xit("fauna function can read  existing record", async function() {
    let fn = fauna.readAuthRecordFromDb;
    assert.ok(fn, "fauna function created");

    let result = await fn(this.client, q, { lookupKey: "myusername" });
    assert.ok(result, "fauna function created");
  });

  it("fauna function add new auth", async function() {
    const collec = "authentications";
    const lookupKey = "mylookup";
    const objeTOAdd = {
      lookupKey: lookupKey,
      authfoo: "ome other raNDOME DATAs",
      authbar: "ya ya"
    };

    // Make sure it is removed
    //username
    let ret;

    try {
      ret = await this.client.query(
        q.Get(q.Match(q.Index(authenticationsIndex), lookupKey))
      );
      var delRes = await this.client.query(
        q.Delete(q.Ref(q.Collection(collec), ret.ref.id))
      );
      assert.ok(delRes);
    } catch (e) {}
    
    let result = null;
    try {
      let adddata = await fauna.createIfNotExists(
        this.client,
        q,
        collec,
        objeTOAdd
      );
      assert.ok(adddata, "fauna function created");

      // Now get this record from db
      let fn2 = fauna.readAuthRecordFromDb;
      result = await fn2(this.client, q, { lookupKey: lookupKey });
    } catch (e) {
      assert.fail(e);
    }
    assert.ok(result, "fauna function created");
    //assert.equal(objeTOAdd.lookupKey, result.lookupKey, 'lookup key should equal');
    assert.equal(objeTOAdd.foo, result.foo, "lookup key should equal");
  });
});
