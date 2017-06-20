/********* FoxitPdf.m Cordova Plugin Implementation *******/

#import "FoxitPdf.h"

static UIViewController* cordovaViewCtrl = nil;
static FSPDFViewCtrl* pdfViewCtrl = nil;
static ReadFrame* readFrame = nil;
static NSString* filePath = nil;
static NSString* password = nil;
static BOOL isScreenLocked = FALSE;
static BOOL isFiledEdited = FALSE;

@implementation FoxitPdf
{
    NSString *tmpCommandCallbackID;
}

+ (UIViewController*)getCordovaViewCtrl {
  return cordovaViewCtrl;
}

+ (void)setCordovaViewCtrl:(UIViewController*)newCordovaViewCtrl {
  if(cordovaViewCtrl != newCordovaViewCtrl) {
    cordovaViewCtrl = newCordovaViewCtrl;
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

    FSPDFViewCtrl *pdfViewCtrl = [[FSPDFViewCtrl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [FoxitPdf setPdfViewCtrl:pdfViewCtrl];

    ReadFrame *readFrame = [[ReadFrame alloc] initWithPdfViewCtrl:pdfViewCtrl];
    [FoxitPdf setReadFrame:readFrame];

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

- (void)Preview:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult = nil;

    // URL
    NSString *filePath = [command.arguments objectAtIndex:0];

    // check file exist
    NSURL *fileURL = [[NSURL alloc] initWithString:filePath];
    BOOL isFileExist = [self isExistAtPath:fileURL.path];

    if (filePath != nil && filePath.length > 0  && isFileExist) {
        [FoxitPdf openPDFAtPath:fileURL.path withPassword:nil];

        // result object
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"preview success"];
        tmpCommandCallbackID = command.callbackId;
    } else {
        NSString* errMsg = [NSString stringWithFormat:@"file not find"];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:@"file not found"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

# pragma mark -- Foxit preview
-(void)FoxitPdfPreview:(NSString *)filePath {
    // DEMO_APPDELEGATE.filePath = filePath;
		//
    // //load doc
    // if (filePath == nil) {
    //     return;
    // }
		//
    // FSPDFDoc* doc = [FSPDFDoc createFromFilePath:filePath];
		//
    // if (e_errSuccess!=[doc load:nil]) {
    //     return;
    // }
		//
    // //init PDFViewerCtrl
    // FSPDFViewCtrl* pdfViewCtrl;
    // pdfViewCtrl = [[FSPDFViewCtrl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // [pdfViewCtrl setDoc:doc];
		//
    // self.readFrame = [[ReadFrame alloc] initWithPdfViewCtrl:pdfViewCtrl];
    // [pdfViewCtrl registerDocEventListener:self.readFrame];
		//
    // UIViewController *navCtr = [[UIViewController alloc] init];
    // [navCtr.view addSubview:pdfViewCtrl];
    // navCtr.view.backgroundColor = [UIColor whiteColor];
    // //    navCtr.modalPresentationStyle = UIModalPresentationFullScreen;
		//
    // pdfViewCtrl.autoresizesSubviews = YES;
    // pdfViewCtrl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		//
		//
    // self.readFrame.CordovaPluginViewController = navCtr;
		//
    // [self.viewController presentViewController:navCtr animated:YES completion:nil];
}

# pragma mark -- close preview
-(void)close{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark -- isExistAtPath
- (BOOL)isExistAtPath:(NSString *)filePath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isExist = [fileManager fileExistsAtPath:filePath];
    return isExist;
}

@end
