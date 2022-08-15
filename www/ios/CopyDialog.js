let exec = require("cordova/exec");

let copyFile = (filePath, name) =>
  new Promise((resolve, reject) => {
    exec(resolve, reject, "CopyDialog", "copyFile", [filePath, name]);
  });

module.exports = {
  copyFile(filePath, type, name) {
    return copyFile(filePath, name);
  },
};
