import { Elm } from "./Main.elm";
const lib = require('./lib');

var flags = {
  api:
    "https://api.themoviedb.org/3/discover/tv?api_key=6aec6123c85be51886e8f69cd9a3a226&first_air_date.gte=2019-01-01&page=1"
};

Elm.Main.init({
  flags: flags
});

let app = Elm.Main.init({
  flags: flags
  //node: document.getElementById("elm")
});

const logInService = new lib.LoginService();
const hedgehog = logInService.hedgehog;




// Subscriptions
app.ports.loginUser.subscribe(function(data) {
  // For testing
  console.log("... User logging in");
  //fakeLogin();
 

  hedgehog
  .login(data.userName, data.password)
  .then(appLoginSendResults)
  .catch((e) => {
    app.ports.hedgeHogloginResult.send({
      address: '',
      isLoggedIn: false,
      message: e.message
    });

  });
});

app.ports.logoutUser.subscribe(function() {
  hedgehog.logout();
  console.log("user logged out");
  app.ports.hedgeHogloginResult.send({
    address: "",
    isLoggedIn: false,
    message: "User Logged out",
    showInfos: []
  });
});



app.ports.registerUser.subscribe(function(data) {
  hedgehog.logout();
 
 
  hedgehog
    .signUp(data.userName, data.password)
    .then(function() {
      app.ports.hedgeHogCreateUserResult.send({
        isCreated: true,
        message: "User Created",
      }); 
    } ,
      e => {
        app.ports.hedgeHogCreateUserResult.send({
            isCreated: false,
            message: e.message
           
        });
      }
    )
    .catch(err =>
      app.ports.hedgeHogCreateUserResult.send({
        isCreated: false,
          message: e.message
         
      }));
});

// Local Functions

function fakeLogin() {
  app.ports.hedgeHogloginResult.send({
    address: "1234",
    isLoggedIn: true,
    message: "Success 2"
  });
}
 
function appLoginSendResults() {
 
      let isLoggedIn = false;
      if (hedgehog.isLoggedIn()) {
        isLoggedIn =  true;
      } else {
        isLoggedIn = hedgehoge.walletExistsLocally && hedgehoge.walletExistsLocally();
      }

      let message= '';
      if (!isLoggedIn) {
        message = 'Login failed.';
      }

      return app.ports.hedgeHogloginResult.send({
        address: isLoggedIn ? hedgehog.getWallet().getAddressString() : '',
        isLoggedIn: isLoggedIn,
        message: message
      });     
  
}

// function isLoggedIn () {
//   if (hedgehog.isLoggedIn()) {
//     return true;
//   } else {
//     return (
//       hh.walletExistsLocally && hh.walletExistsLocally()
//     );
//   }
// }