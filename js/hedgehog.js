import { Firebase } from './firebase.js';

const AUTH_TABLE = "Authentications";
const USER_TABLE = "Users";
const firebaseService = new Firebase();
const setAuthFn = async obj =>
firebaseService.createIfNotExists(AUTH_TABLE, obj.lookupKey, obj);
const setUserFn = async obj =>
firebaseService.createIfNotExists(USER_TABLE, obj.username, obj);
const getFn = async obj => firebaseService.readRecordFromFirebase(AUTH_TABLE, obj);


export const hedgehog = new Hedgehog(getFn, setAuthFn, setUserFn);
