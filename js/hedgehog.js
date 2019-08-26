
import { Fauna } from './fauna.js';

const AUTH_COL = "authentications";
const USER_COL = "users";

const faunaService = new Fauna();
console.log('fauna service: ' +faunaService);
const setAuthFn = async obj =>
faunaService.createIfNotExists(AUTH_COL, obj);
const setUserFn = async obj =>
faunaService.createIfNotExists(USER_COL, obj);
const getFn = async obj => faunaService.readAuthRecordFromDb(obj); 


export const hedgehog = new Hedgehog(getFn, setAuthFn, setUserFn);
