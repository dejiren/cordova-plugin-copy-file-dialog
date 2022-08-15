let exec = require("cordova/exec");
const fileStoreKey = "cordova-plugin-copy-file-tem-filePath";
let locateFile = (type, name) =>
  new Promise((resolve, reject) => {
    exec(resolve, reject, "CopyDialog", "locateFile", [type || "application/octet-stream", name]);
  });

let copyFile = (targetUri, srcUri) =>
  new Promise((resolve, reject) => {
    exec(resolve, reject, "CopyDialog", "copyFile", [targetUri, srcUri]);
  });

let storage = window.localStorage;

module.exports = {
  copyFile(srcUri, type, name = "") {
    var storage = window.localStorage;

    storage.setItem(fileStoreKey, srcUri); // Pass a key name and its value to add or update that key.

    return locateFile(type, name)
      .then((uri) => copyFile(uri, srcUri))
      .catch((reason) => {
        return Promise.reject(reason);
      });
  },
};

// If Android OS has destroyed the Cordova Activity in background, try to complete the copy operation
// https://cordova.apache.org/docs/en/10.x/guide/platforms/android/plugin.html#launching-other-activities
document.addEventListener(
  "resume",
  ({ pendingResult = {} }) => {
    if (pendingResult.pluginServiceName !== "CopyDialog") {
      return;
    }
    if (pendingResult.pluginStatus !== "OK" || !pendingResult.result) {
      return;
    }
    copyFile(
      pendingResult.result,
      storage.getItem(fileStoreKey) // Pass a key name to get its value.
    )
      .catch((reason) => {
        console.warn("[CopyDialog]", reason);
      })
      .finally(() => storage.removeItem(fileStoreKey));
  },
  false
);
