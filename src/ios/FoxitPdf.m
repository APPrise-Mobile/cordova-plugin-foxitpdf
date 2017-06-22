/********* FoxitPdf.m Cordova Plugin Implementation *******/

#import "FoxitPdf.h"

static id <CDVCommandDelegate> cordovaCommandDelegate;
static UIViewController* cordovaViewCtrl = nil;
static FSPDFViewCtrl* pdfViewCtrl = nil;
static ReadFrame* readFrame = nil;
static NSString* filePath = nil;
static NSString* password = nil;
static BOOL isScreenLocked = FALSE;
static BOOL isFiledEdited = FALSE;
static NSString* tmpCommandCallbackID;

@implementation FoxitPdf

+ (UIViewController*)getCordovaViewCtrl {
  return cordovaViewCtrl;
}

+ (void)setCordovaViewCtrl:(UIViewController*)newCordovaViewCtrl {
  if(cordovaViewCtrl != newCordovaViewCtrl) {
    cordovaViewCtrl = newCordovaViewCtrl;
  }
}

+ (id <CDVCommandDelegate>) getCordovaCommandDelegate {
  return cordovaCommandDelegate;
}

+ (void) setCordovaCommandDelegate:(id <CDVCommandDelegate>)newCordovaCommandDelegate {
  if(cordovaCommandDelegate != newCordovaCommandDelegate) {
    cordovaCommandDelegate = newCordovaCommandDelegate;
  }
}

+ (FSPDFViewCtrl*)getPdfViewCtrl {
    return pdfViewCtrl;
}

+ (void)setPdfViewCtrl:(FSPDFViewCtrl*)newPdfViewCtrl {
    if(pdfViewCtrl != newPdfViewCtrl) {
        pdfViewCtrl = newPdfViewCtrl;
    }
}

+ (ReadFrame*)getReadFrame {
    return readFrame;
}

+ (void)setReadFrame:(ReadFrame*)newReadFrame {
    if(readFrame != newReadFrame) {
        readFrame = newReadFrame;
    }
}

+ (NSString*)getTmpCommandCallbackID {
    return tmpCommandCallbackID;
}
+ (void)setTmpCommandCallbackID:(NSString*)newTmpCommandCallbackID {
    if(tmpCommandCallbackID != newTmpCommandCallbackID) {
        tmpCommandCallbackID = newTmpCommandCallbackID;
    }
}

+ (NSString*)getFilePath {
    return filePath;
}
+ (void)setFilePath:(NSString*)newFilePath {
    if(filePath != newFilePath) {
        filePath = newFilePath;
    }
}

+ (NSString*)getPassword {
    return password;
}
+ (void)setPassword:(NSString*)newPassword {
    if(password != newPassword) {
        password = newPassword;
    }
}

+ (BOOL)isScreenLocked {
    return isScreenLocked;
}

+ (void)setIsScreenLocked:(BOOL)newIsScreenLocked {
    if(isScreenLocked != newIsScreenLocked) {
        isScreenLocked = newIsScreenLocked;
    }
}

+ (BOOL)isFileEdited {
    return isFiledEdited;
}

+ (void)setIsFileEdited:(BOOL)newIsFileEdited {
    if(isFiledEdited != newIsFileEdited) {
        isFiledEdited = newIsFileEdited;
    }
}

+ (void)close {
    NSString *tmpCommandCallbackID = [FoxitPdf getTmpCommandCallbackID];
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"pdf closed"];
    [[FoxitPdf getCordovaCommandDelegate] sendPluginResult:pluginResult callbackId:tmpCommandCallbackID];
    [[FoxitPdf getCordovaViewCtrl] dismissViewControllerAnimated:YES completion:nil];
}

+ (BOOL)openPDFAtPath:(NSString*)path withPassword:(NSString*)password
{
    FSPDFDoc* pdfDoc = [FSPDFDoc createFromFilePath:path];
    if (nil == pdfDoc) {
        return NO;
    }
    [FoxitPdf setFilePath:nil];
    [FoxitPdf setPassword:nil];

    ReadFrame *readFrame = [FoxitPdf getReadFrame];
    [readFrame.passwordModule tryLoadPDFDocument:pdfDoc guessPassword:password success:^(NSString *password) {
        [FoxitPdf setFilePath:path];
        [FoxitPdf setPassword:password];
        FSPDFViewCtrl* pdfViewCtrl = [FoxitPdf getPdfViewCtrl];
        [pdfViewCtrl setDoc:pdfDoc];

        UIViewController* pdfViewController = [[UIViewController alloc] init];
        pdfViewController.view = pdfViewCtrl;
        pdfViewController.automaticallyAdjustsScrollViewInsets = NO;
        UIViewController *cordovaViewCtrl = [FoxitPdf getCordovaViewCtrl];
        [cordovaViewCtrl presentViewController:pdfViewController animated:YES completion:nil];
    } error:^(NSString* description) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"kFailOpenFile", nil), [path lastPathComponent]]
                                                        message:description
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"kOK", nil) otherButtonTitles:nil, nil];
        [alert show];
    } abort:^{
        FSPDFViewCtrl* pdfViewCtrl = [FoxitPdf getPdfViewCtrl];
        [pdfViewCtrl closeDoc:nil];
    }];

    return YES;
}

- (void)init:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult = nil;

    [FoxitPdf setCordovaViewCtrl:self.viewController];
    [FoxitPdf setCordovaCommandDelegate:self.commandDelegate];

    // URL
    NSString *serial = [command.arguments objectAtIndex:0];
    NSString *key = [command.arguments objectAtIndex:1];
    // init foxit sdk
    enum FS_ERRORCODE eRet = [FSLibrary init:serial key:key];
    if (e_errSuccess != eRet) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:@"FoxitPdf: Invalid license"];
    } else {
      pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"FoxitPdf: init success"];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)openPdf:(CDVInvokedUrlCommand*)command
{
    // URL
    NSString *filePath = [command.arguments objectAtIndex:0];
    NSDictionary *options = [command argumentAtIndex:1];

    FSPDFViewCtrl *pdfViewCtrl = [[FSPDFViewCtrl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [FoxitPdf setPdfViewCtrl:pdfViewCtrl];
    ReadFrame *readFrame = [[ReadFrame alloc] initWithPdfViewCtrl:pdfViewCtrl options:options];
    [FoxitPdf setReadFrame:readFrame];

    // check file exist
    NSURL *fileURL = [[NSURL alloc] initWithString:filePath];
    BOOL isFileExist = [self isExistAtPath:fileURL.path];

    if (filePath != nil && filePath.length > 0  && isFileExist) {
        [FoxitPdf setTmpCommandCallbackID:command.callbackId];
        [FoxitPdf openPDFAtPath:fileURL.path withPassword:nil];
    } else {
        NSString* errMsg = [NSString stringWithFormat:@"file not find"];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:@"file not found"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }

}

# pragma mark -- isExistAtPath
- (BOOL)isExistAtPath:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    return isExist;
}

@end
