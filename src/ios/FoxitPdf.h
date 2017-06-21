
#import <Cordova/CDV.h>
#import <FoxitRDK/FSPDFObjC.h>
#import <FoxitRDK/FSPDFViewControl.h>

#import "ReadFrame.h"
#import "PasswordModule.h"
#import "UIExtensionsSharedHeader.h"

@class UIExtensionsManager;
@class ReadFrame;

@interface FoxitPdf : CDVPlugin

+ (id <CDVCommandDelegate>) getCordovaCommandDelegate;
+ (void) setCordovaCommandDelegate:(id <CDVCommandDelegate>)newCordovaCommandDelegate;

+ (UIViewController*)getCordovaViewCtrl;
+ (void)setCordovaViewCtrl:(UIViewController*)newCordovaViewCtrl;

+ (FSPDFViewCtrl*)getPdfViewCtrl;
+ (void)setPdfViewCtrl:(FSPDFViewCtrl*)newPdfViewCtrl;

+ (ReadFrame*)getReadFrame;
+ (void)setReadFrame:(ReadFrame*)newReadFrame;

+ (NSString*)getTmpCommandCallbackID;
+ (void)setTmpCommandCallbackID:(NSString*)newTmpCommandCallbackID;

+ (NSString*)getFilePath;
+ (void)setFilePath:(NSString*)newFilePath;

+ (NSString*)getPassword;
+ (void)setPassword:(NSString*)newPassword;

+ (BOOL)isScreenLocked;
+ (void)setIsScreenLocked:(BOOL)newIsScreenLocked;

+ (BOOL)isFileEdited;
+ (void)setIsFileEdited:(BOOL)newIsFileEdited;

+ (BOOL)openPDFAtPath:(NSString*)path withPassword:(NSString*)password;
+ (void)close;

@end
