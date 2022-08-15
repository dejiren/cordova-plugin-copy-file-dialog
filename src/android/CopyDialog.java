package io.github.dejiren;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.os.ParcelFileDescriptor;
// import android.provider.DocumentsContract;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaResourceApi;

import org.json.JSONArray;
import org.json.JSONException;

import java.io.FileOutputStream;
import java.net.URI;
import java.io.FileInputStream;

public class CopyDialog extends CordovaPlugin {
    private static final int LOCATE_FILE = 1;

    private CallbackContext callbackContext;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        if (action.equals("locateFile")) {
            this.locateFile(args.getString(0), args.getString(1));
        } else if (action.equals("copyFile")) {
            this.copyFile(Uri.parse(args.getString(0)), args.getString(1));
        } else {
            return false;
        }
        return true;
    }

    private void locateFile(String type, String name) {
        Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT);
        intent.addCategory(Intent.CATEGORY_OPENABLE);
        intent.setType(type);
        intent.putExtra(Intent.EXTRA_TITLE, name);
        // TODO Optionally, specify a URI for the directory that should be opened in
        // the system file picker when your app creates the document.
        // intent.putExtra(DocumentsContract.EXTRA_INITIAL_URI, pickerInitialUri);
        cordova.startActivityForResult(this, intent, CopyDialog.LOCATE_FILE);
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent resultData) {
        if (requestCode == CopyDialog.LOCATE_FILE && this.callbackContext != null) {
            if (resultCode == Activity.RESULT_CANCELED) {
                this.callbackContext.error("The dialog has been cancelled");
            } else if (resultCode == Activity.RESULT_OK && resultData != null) {
                Uri uri = resultData.getData();
                this.callbackContext.success(uri.toString());
            } else {
                this.callbackContext.error("Unknown error");
            }
        }
    }

    public void onRestoreStateForActivityResult(Bundle state, CallbackContext callbackContext) {
        this.callbackContext = callbackContext;
    }

    private void copyFile(Uri targetUri, String srcFilePath) {
        String fileName = "";
        try {
            CordovaResourceApi resourceApi = webView.getResourceApi();
            Uri fileUri = resourceApi.remapUri(Uri.parse(srcFilePath));
            fileName = fileUri.getPath();
        } catch (Exception e) {
            fileName = srcFilePath;
        }
        try {
            ParcelFileDescriptor pfd = cordova.getActivity().getContentResolver().openFileDescriptor(targetUri, "w");
            FileOutputStream fileOutputStream = new FileOutputStream(pfd.getFileDescriptor());
            FileInputStream inputStream = new FileInputStream(fileName);
            byte[] buffer = new byte[1024];
            try {
                while (inputStream.read(buffer) > 0) {
                    fileOutputStream.write(buffer);
                }
                this.callbackContext.success();
            } catch (Exception e) {
                this.callbackContext.error(e.getMessage());
                e.printStackTrace();
            } finally {
                fileOutputStream.close();
                inputStream.close();
                pfd.close();
            }
        } catch (Exception e) {
            this.callbackContext.error(e.getMessage());
            e.printStackTrace();
        }
    }
}
