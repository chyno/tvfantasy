import { hedgehog } from "./hedgehog.js";
import { getLatestTvsShow } from "./tvapi.js";
let app = Elm.Main.init({
  flags: "Hello",
  node: document.getElementById("elm")
});



// Subscriptions 
app.ports.loginUser.subscribe(function(data) {
  // For testing
  console.log("... User logging in");
  fakeLogin();
  // appLoginSendResults(data);
});
 

app.ports.logoutUser.subscribe(function() {
  hedgehog.logout();
  console.log("user logged out");
  app.ports.loginResult.send({
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

app.ports.startLoadShows.subscribe(function(data) {
 // const tvShows = getFakeTvShows();
 // app.ports.showApiResults.send(tvShows);
 getLatestTvsShow().then(showData => {
  app.ports.showApiResults.send(showData);
 });
  
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
  app.ports.loginResult.send({
         address: '1234',
         isLoggedIn: true,
         message: "Success 2",
        
       });
}

function appLoginSendResults(data) {
  hedgehog.login(data.userName, data.password).then(
   () => {
     getLatestTvsShow().then(showData => {
       app.ports.loginResult.send({
         address: hedgehog.getWallet().getAddressString(),
         isLoggedIn: isLoggedIn(),
         message: "Success"
          
       });
     });
   },
   e => {
     app.ports.loginResult.send({
       address: "",
       isLoggedIn: false,
       message: "Invalid Username or password" 
     });
   }
 );

}
// showApiResults
function getFakeTvShows()  {
   return [
     {
       
        name: "Friends",
        country: "US",
        overview: "Lame show",
        firstAirDate: "01912002",
        voteAverage: 2
        
     }
   ];

}

