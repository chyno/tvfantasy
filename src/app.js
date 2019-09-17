import { Elm } from "./Main.elm";
//import { hedgehog } from "./js/hedgehog.js";


var flags = {
  api: 'https://api.themoviedb.org/3/discover/tv?api_key=6aec6123c85be51886e8f69cd9a3a226&first_air_date.gte=2019-01-01&page=1'
};

Elm.Main.init({
     flags: flags
});

let app = Elm.Main.init({
  flags: flags,
   //node: document.getElementById("elm")
});


// Subscriptions 
app.ports.loginUser.subscribe(function(data) {
  // For testing
  console.log("... User logging in");
  fakeLogin();
  // appLoginSendResults(data);
});
 

// app.ports.logoutUser.subscribe(function() {
//   hedgehog.logout();
//   console.log("user logged out");
//   app.ports.loginResult.send({
//     address: "",
//     isLoggedIn: false,
//     message: "User Logged out",
//     showInfos: []
//   });
// });

app.ports.registerUser.subscribe(function(data) {
  hedgehog.logout();

  hedgehog
    .signUp(data.userName, data.password)
    .then(
      () => {
        app.ports.loginResult.send({
          address: "",
          isLoggedIn: false,
          message: "User Created",
          showInfos: []
        });
      },
      e => {
        app.ports.loginResult.send({
          address: "",
          isLoggedIn: false,
          message: e.message,
          showInfos: []
        });
      }
    )
    .catch(err =>
      app.ports.loginResult.send({
        address: "",
        isLoggedIn: false,
        message: err.message,
        showInfos: []
      })
    );
});


// Local Functions
function isLoggedIn() {
  if (hedgehog.isLoggedIn()) {
    return true;
  } else {
    return (
      hedgehog && hedgehog.walletExistsLocally && hedgehog.walletExistsLocally()
    );
  }
}

function fakeLogin () {
  app.ports.hedgeHogloginResult.send({
         address: '1234',
         isLoggedIn: true,
         message: "Success 2",
        
       });
}


