import faunadb, { query as q } from "faunadb";

var client = new faunadb.Client({ secret: 'YOUR_FAUNADB_SECRET' });
const userName = 'test1';

client.query(
    q.CreateIndex(
      { name: "users_by_username",
        source: q.Collection("users"),
        terms: [{ field: ["data", "username"] }] }))
  .then((ret) => 
  {
    console.log(ret);
    // Add record
    client.query(
        q.Create(
          q.Collection("users"),
          { data: { username: userName, foo:'bar' } }))
      .then((ret) => { 
          console.log(ret);
          // Now lets retreive
          client.query(q.Get(q.Ref(q.Collection("posts"), "192903209792046592")))
          .then((ret) => console.log(ret))

        });
  }
  );

  