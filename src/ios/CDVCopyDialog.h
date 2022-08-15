#import <Cordova/CDVPlugin.h>
#import <UIKit/UIKit.h>

@interface CDVCopyDialog : CDVPlugin <UIDocumentPickerDelegate>

@property (nonatomic, retain) NSString* callbackId;

- (void)copyFile:(CDVInvokedUrlCommand*)command;
- (NSURL*)getPluginDirectory;
- (void)sendPluginResult:(BOOL)success message:(NSString*)message;

@end
