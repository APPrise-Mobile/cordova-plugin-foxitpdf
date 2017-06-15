/********* FoxitPdf.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>

#import <FoxitRDK/FSPDFObjC.h>
#import <FoxitRDK/FSPDFViewControl.h>
#import "ReadFrame.h"
#import "UIExtensionsSharedHeader.h"

@interface FoxitPdf : CDVPlugin {
    // Member variables go here.
}

@property (nonatomic, strong) ReadFrame* readFrame;
- (void)init:(CDVInvokedUrlCommand*)command;
- (void)Preview:(CDVInvokedUrlCommand*)command;
@end

@implementation FoxitPdf
{
    NSString *tmpCommandCallbackID;
}

- (void)init:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult *pluginResult = nil;

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
        // preview
        [self FoxitPdfPreview:fileURL.path];

        // result object
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"preview success"];
        tmpCommandCallbackID = command.callbackId;
    } else {
        NSString* errMsg = [NSString stringWithFormat:@"file not find"];
        UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" message:errMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] autorelease];
        [alert show];

        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR  messageAsString:@"file not found"];
    }

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];

}

# pragma mark -- Foxit preview
-(void)FoxitPdfPreview:(NSString *)filePath {
    DEMO_APPDELEGATE.filePath = filePath;

    //load doc
    if (filePath == nil) {
        return;
    }

    FSPDFDoc* doc = [FSPDFDoc createFromFilePath:filePath];

    if (e_errSuccess!=[doc load:nil]) {
        return;
    }

    //init PDFViewerCtrl
    FSPDFViewCtrl* pdfViewCtrl;
    pdfViewCtrl = [[FSPDFViewCtrl alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [pdfViewCtrl setDoc:doc];

    self.readFrame = [[ReadFrame alloc] initWithPdfViewCtrl:pdfViewCtrl];
    [pdfViewCtrl registerDocEventListener:self.readFrame];

    UIViewController *navCtr = [[UIViewController alloc] init];
    [navCtr.view addSubview:pdfViewCtrl];
    navCtr.view.backgroundColor = [UIColor whiteColor];
    //    navCtr.modalPresentationStyle = UIModalPresentationFullScreen;

    pdfViewCtrl.autoresizesSubviews = YES;
    pdfViewCtrl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;


    self.readFrame.CordovaPluginViewController = navCtr;

    [self.viewController presentViewController:navCtr animated:YES completion:nil];
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
