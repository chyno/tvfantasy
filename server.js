var compile = require("node-elm-compiler").compile;
var connect = require('connect');
var serveStatic = require('serve-static');
//const express = require('express');
//const app = express();

// compile(["./src/Main.elm"], {
//   output: "dist/elmapp.js"
// }).on('close', function(exitCode) {
//   console.log("Finished with exit code", exitCode);
// });

//app.use(express.static('dist'));


//app.listen(8080, () => console.log('Server running on 8080...'));

connect().use(serveStatic('C:\\dev\\tvfantasy\\dist')).listen(8080, function(){
    console.log('Server running on 8080...');
});


