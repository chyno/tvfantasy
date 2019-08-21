var compile = require("node-elm-compiler").compile;
var connect = require('connect');
var serveStatic = require('serve-static');

compile(["./src/Main.elm"], {
  output: "dist/elmapp.js"
}).on('close', function(exitCode) {
  console.log("Finished with exit code", exitCode);

});
