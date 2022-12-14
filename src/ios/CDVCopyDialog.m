#import "CDVCopyDialog.h"
#import <Cordova/CDVPlugin.h>
#import <UIKit/UIKit.h>

@implementation CDVCopyDialog

- (void)copyFile:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    if (@available(iOS 14, *)) {
        NSString* filePath = [command.arguments objectAtIndex:0];
        NSString* name = [command.arguments objectAtIndex:1];
        
        NSURL *localFileUrl = NULL;
		NSString *decodedPath = [filePath stringByRemovingPercentEncoding];

		if ([filePath isEqualToString:decodedPath]) {
			NSLog(@"Path parameter not encoded. Building file URL encoding it...");
			localFileUrl = [NSURL fileURLWithPath:[filePath stringByReplacingOccurrencesOfString:@"file://" withString:@""]];;
		} else {
			NSLog(@"Path parameter already encoded. Building file URL without encoding it...");
			localFileUrl = [NSURL URLWithString:filePath];
		}

        NSError *err;
        if ([localFileUrl checkResourceIsReachableAndReturnError:&err] == NO) {
            [self sendPluginResult:NO message:@"Cannot get a local file"];
            return;
        }

        NSArray* urls = @[localFileUrl];
        UIDocumentPickerViewController* picker = [[UIDocumentPickerViewController alloc] initForExportingURLs:urls asCopy:YES];
        picker.shouldShowFileExtensions = YES;
        picker.delegate = self;
        [self.viewController presentViewController:picker animated:YES completion:nil];
    } else {
        [self sendPluginResult:NO message:@"Unsupported iOS version"];
    }
}

- (void)documentPicker:(UIDocumentPickerViewController*)picker didPickDocumentsAtURLs:(NSArray<NSURL*>*)urls
{
    if ([urls count] > 0) {
        [self sendPluginResult:YES message:nil];
    } else {
        [self sendPluginResult:NO message:@"Unknown error"];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController*)picker
{
    [self sendPluginResult:NO message:@"The dialog has been cancelled"];
}

- (NSURL*)getPluginDirectory
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSURL* documentDir = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    return [documentDir URLByAppendingPathComponent:@".CopyDialog" isDirectory:YES];
}

// Delete the file after copy a file
// - (NSURL*)createTemporaryLocalFile:(NSData*)data fileName:(NSString*)name
// {
//     NSURL* pluginDir = [self getPluginDirectory];
//     NSFileManager* fileManager = [NSFileManager defaultManager];
//     if (![fileManager createDirectoryAtURL:pluginDir withIntermediateDirectories:YES attributes:nil error:nil]) {
//         return nil;
//     }
//     NSURL* localFileUrl = [pluginDir URLByAppendingPathComponent:name isDirectory:NO];
//     if (![data writeToURL:localFileUrl atomically:YES]) {
//         return nil;
//     }
//     return localFileUrl;
// }

// - (void)deleteTemporaryLocalFiles
// {
//     NSURL* pluginDir = [self getPluginDirectory];
//     NSFileManager* fileManager = [NSFileManager defaultManager];
//     [fileManager recopyItemAtURL:pluginDir error:nil];
// }

- (void)sendPluginResult:(BOOL)success message:(NSString*)message
{
    CDVPluginResult* pluginResult = nil;
    if (success) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:message];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

@end
