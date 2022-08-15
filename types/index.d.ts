interface CordovaPlugins {
  copyDialog: { copyFile: (filePath: string, type: string, fileName: string) => Promise<any> };
}
