export class Firebase {
  constructor() {
     
    var config = {
      apiKey: "AIzaSyABtuHG_Z04vvJ3qH7BC5FsxiJoDiQxXK8",
      authDomain: "hedgehoge-demo.firebaseapp.com",
      databaseURL: "https://hedgehoge-demo.firebaseio.com",
      projectId: "hedgehoge-demo",
      storageBucket: "hedgehoge-demo.appspot.com",
      messagingSenderId: "701426659131",
      appId: "1:701426659131:web:fe33c7c7e1e1a213"
      };
    this.app = firebase.initializeApp(config);
    this.db = firebase.firestore(this.app);
  }

  async writeToFirebase(tableName, primaryKey, data) {
    try {
      await this.db
        .collection(tableName)
        .doc(primaryKey)
        .set(data);
      console.log("Document successfully written!");
    } catch (e) {
      console.error("Error writing document: ", e);
    }
  }

  async createIfNotExists(tableName, primaryKey, data) {
    try {
      var docRef = await this.db
        .collection(tableName)
        .doc(primaryKey)
        .get();
      if (docRef.exists) {
        throw new Error(`Document exists for lookupKey ${primaryKey}`);
      } else {
        return this.writeToFirebase(tableName, primaryKey, data);
      }
    } catch (e) {
      throw e;
    }
  }

  async readRecordFromFirebase(tableName, obj) {
    let lookupKey = obj.lookupKey;
    try {
      var docRef = await this.db
        .collection(tableName)
        .doc(lookupKey)
        .get();
      return docRef.data();
    } catch (e) {
      throw e;
    }
  }
}

