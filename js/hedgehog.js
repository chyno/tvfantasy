import { faunaService } from "./faunadb.js";

//var faunaService = require("./fauna.js");

const AUTH_COL = "authentications";
const USER_COL = "users";
const client = new faunadb.Client({ secret: faunaService.secretAdminKey });
const q = faunadb.query;

console.log('fauna service: ' +faunaService);
// const setAuthFn = async obj =>
// faunaService.createIfNotExists(AUTH_COL, obj);
// const setUserFn = async obj =>
// faunaService.createIfNotExists(USER_COL, obj);
// const getFn = async obj => faunaService.readAuthRecordFromDb(obj); 


const setAuthFn = async obj =>
faunaService.createIfNotExists(client, q, AUTH_COL, obj);
const setUserFn = async obj =>
faunaService.createIfNotExists(client, q, USER_COL, obj);
const getFn = async obj => faunaService.readAuthRecordFromDb(client, q, obj); 


export const hedgehog = new Hedgehog(getFn, setAuthFn, setUserFn);
