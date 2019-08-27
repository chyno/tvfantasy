import { hedgehog } from './hedgehog.js';
import {apiUrl} from './tvapi.js';
let app = Elm.Main.init({
  flags: "Hello",
  node: document.getElementById("elm")
});

app.ports.loginUser.subscribe(function(data) {
  // For testing
  console.log('... User logging in');
  // app.ports.loginResult.send({
  //         address: '1234',
  //         isLoggedIn: true,
  //         message: "Success 2",
  //         showInfos : [
  //           {name: 'friends', description: 'lame show'},
  //           {name: 'Silicon valley', description: 'about computer geeks'}
  //         ]
  //       });

  hedgehog.login(data.userName, data.password).then(
    () => {
      apiUrl().then(showData => {
        app.ports.loginResult.send({
          address: hedgehog.getWallet().getAddressString(),
          isLoggedIn: isLoggedIn(),
          message: "Success",
          showInfos: showData
        });
      });
    },
    e => {
      app.ports.loginResult.send({
        address: "",
        isLoggedIn: false,
        message: 'Invalid Username or password',
        showInfos: []
      });
    }
 );
});

app.ports.logoutUser.subscribe(function() {
  hedgehog.logout();
  console.log("user logged out");
  app.ports.loginResult.send({
    address: "",
    isLoggedIn: false,
    message: "User Logged out",
    showInfos : []
  });
});

app.ports.registerUser.subscribe(function(data) {
  hedgehog.logout();

  hedgehog.signUp(data.userName, data.password)
  .then(
    () => {
      app.ports.loginResult.send({
        address: "",
        isLoggedIn: false,
        message: "User Created",
        showInfos : []
      });
    },
    e => {
      app.ports.loginResult.send({
        address: "",
        isLoggedIn: false,
        message: e.message,
        showInfos : []
      });
    }
  )
  .catch(err => app.ports.loginResult.send({
    address: "",
    isLoggedIn: false,
    message: err.message,
    showInfos : []
  }));
});


function isLoggedIn() {
  if (hedgehog.isLoggedIn()) {
    return true;
  } else {
    return (
      hedgehog && hedgehog.walletExistsLocally && hedgehog.walletExistsLocally()
    );
  }
}


