let getDataObj = function() {
  function writeTo(db, lookupKey, data) {
    db[lookupKey] = data;
  }

  return {
    db: {},
    createIfNotExists: function(lookupKey, data) {
      let self = this;
      try {
        if (!self.db) {
          throw new Error(`Document exists for lookupKey ${primaryKey}`);
        } else {
          return new Promise(resolve => {
            writeTo(self.db, lookupKey, data);
            resolve(undefined);
          });
        }
      } catch (e) {
        throw e;
      }
    },

    readRecord: function(obj) {
      let self = this;
      let lookupKey = obj.lookupKey;
      try {
        return new Promise(resolve => resolve(self.db[lookupKey]));
      } catch (e) {
        throw e;
      }
    }
  };
};
module.exports = getDataObj;
