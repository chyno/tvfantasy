var assert = require("assert");
var faunadb = require('faunadb'),
  q = faunadb.query;
  const userIndex = 'users_by_username';
  const secretAdminKey = "fnADWu_uwLACCI7LXiCJ7Szqvqjvk8BFndUFRMvy";
 // const secretClientKey = 'fnADWgKmE-ACCNt8DvTuqmsjsRC71C3AcoGbPJ7x';
//var client = new faunadb.Client({ secret: 'YOUR_FAUNADB_SECRET' });

describe("Raw testing of Fauna Javascript API", function() {
    let client = null;

    beforeEach(async function() {
      client = new faunadb.Client({ secret: secretAdminKey });
    });
  
    it("Can create client", function() {
      assert.ok(client, "fauna client created");
    });
    
    

    xit('Can Create an index on the users’s username:', async function() {
      let item = q.CreateIndex(
        { name: userIndex,
          source: q.Collection("users"),
          terms: [{ field: ["data", "username"] }] });
      try {
      let ret = await client.query(item);
      console.log(ret);
      } catch (e) {
        const resp = e.requestResult.responseRaw;
        console.log(resp);
        assert.fail(e,resp);
    }
      //.then((ret) => console.log(ret)
      
    });

    xit('can add record', async function() {
      let item = q.Create(
        q.Collection("users"),
        { data: { username: "myusername", foo: 'bar' } });

        assert(item);
        try {
          let ret = await client.query(item);
          console.log(ret);
          assert(ret);
        } catch (e) {
          const resp = e.requestResult.responseRaw;
          console.log(resp);
          assert.fail(e,resp);
      }
    });

    xit('can get user record by id ', async function() {
    
       // assert(item);
        try {
          let ret = await client.query(q.Get(q.Ref(q.Collection("users"), "241771288921637384")));

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
          assert.fail(e,resp);
      }
    });

    it('can get user record by username ', async function() {
      const userName = 'myusername';
      // assert(item);
       try {
        let ret = await client.query(
          q.Get(
            q.Match(q.Index(userIndex), userName)));
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
         assert.fail(e,resp);
     }
   });
});