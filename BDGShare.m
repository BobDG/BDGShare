//
//  BDGShare.m
//
//  Created by Bob de Graaf on 09-10-14.
//  Copyright (c) 2014 GraafICT. All rights reserved.
//

#import <Social/Social.h>

#import "BDGShare.h"
#import "WhatsAppActivity.h"

static NSString *kWhatsAppUrlScheme = @"whatsapp://";

@interface BDGShare () <UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
{
    
}

@property(nonatomic,copy) void (^shareCompleted)(SharingResult sharingResult);
@property(nonatomic,strong) UIDocumentInteractionController *documentInteractionController;

@end

@implementation BDGShare

#pragma mark Init

-(id)init
{
    self = [super init];
    if(self) {
        //Init excluded array
        self.excludeActivities = @[UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
        
        //Statusbarstyle
        self.statusBarStyle = [[UIApplication sharedApplication] statusBarStyle];
    }
    return self;
}

#pragma mark Share using Service Type

-(void)shareUsingServiceType:(NSString *)serviceType text:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion
{
    self.shareCompleted = completion;
    
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:serviceType];
    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result) {
        [controller dismissViewControllerAnimated:YES completion:nil];
        switch(result) {
            case SLComposeViewControllerResultCancelled: {
                [self completeWithResult:SharingResultCancelled];
                break;
            }
            case SLComposeViewControllerResultDone: {
                [self completeWithResult:SharingResultSuccess];
                break;
            }
        }};
    if(nil != image) {
        [controller addImage:image];
    }
    if(urlStr.length>0) {
        [controller addURL:[NSURL URLWithString:urlStr]];
    }
    if(text.length>0) {
        [controller setInitialText:text];
    }
    [controller setCompletionHandler:completionHandler];
    UIViewController *presentingController = [self presentingVC];
    [presentingController presentViewController:controller animated:TRUE completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
    }];
    CFRunLoopWakeUp(CFRunLoopGetCurrent());
}

-(void)shareTwitter:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareUsingServiceType:SLServiceTypeTwitter text:text urlStr:urlStr image:image completion:completion];
}

-(void)shareFacebook:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareUsingServiceType:SLServiceTypeFacebook text:text urlStr:urlStr image:image completion:completion];
}

-(void)shareWeibo:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareUsingServiceType:SLServiceTypeSinaWeibo text:text urlStr:urlStr image:image completion:completion];
}

#pragma mark Share using Activity Controller

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image whatsapp:(BOOL)whatsapp popoverRect:(CGRect)popoverRect completion:(void (^)(UIActivityViewController *activityViewController))completion
{
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    if(text.length>0) {
        [activities addObject:text];
    }
    if(urlStr.length>0) {
        [activities addObject:[NSURL URLWithString:urlStr]];
    }
    if(nil != image) {
        [activities addObject:image];
    }
    
    NSMutableArray *applicationActivities = [[NSMutableArray alloc] init];
    if(whatsapp && [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kWhatsAppUrlScheme]]) {
        [applicationActivities addObject:[[WhatsAppActivity alloc] init]];
    }
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:activities applicationActivities:applicationActivities];
    controller.excludedActivityTypes = self.excludeActivities;
    
    //Completion handler
    if([[UIDevice currentDevice] systemVersion].floatValue >= 8.0) {
        [controller setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            [self completeWithResult:completed ?  SharingResultSuccess : SharingResultFailed];
        }];
    }
    else {
        //Silence deprecation warning since we're already taking this into account
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [controller setCompletionHandler:^(NSString *activityType, BOOL completed) {
            [self completeWithResult:completed ?  SharingResultSuccess : SharingResultFailed];
        }];
#pragma clang diagnostic pop
    }
    
    //Completion handler means the dev wants to present the activitycontroller himself
    if(completion) {
        completion(controller);
        return;
    }
    
    UIViewController *presentingController = [self presentingVC];
    //iOS8 needs the popoverPresentationController
    bool isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    if(isPad && [controller respondsToSelector:@selector(popoverPresentationController)]) {
        controller.popoverPresentationController.sourceView = presentingController.view;
        if(!CGRectIsEmpty(popoverRect)) {
            controller.popoverPresentationController.sourceRect = popoverRect;
        }
    }
    
    //Present
    [presentingController presentViewController:controller animated:TRUE completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
    CFRunLoopWakeUp(CFRunLoopGetCurrent());
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image completion:(void (^)(UIActivityViewController *activityViewController))completion
{
    [self shareUsingActivityController:text urlStr:urlStr image:image whatsapp:FALSE popoverRect:CGRectZero completion:completion];
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image whatsapp:(BOOL)whatsapp popoverRect:(CGRect)popoverRect
{
    [self shareUsingActivityController:text urlStr:urlStr image:image whatsapp:whatsapp popoverRect:popoverRect completion:nil];
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image whatsapp:(BOOL)whatsapp
{
    [self shareUsingActivityController:text urlStr:urlStr image:image whatsapp:whatsapp popoverRect:CGRectZero completion:nil];
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image popoverRect:(CGRect)popoverRect
{
    [self shareUsingActivityController:text urlStr:urlStr image:image whatsapp:FALSE popoverRect:popoverRect completion:nil];
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image
{
    [self shareUsingActivityController:text urlStr:urlStr image:image whatsapp:FALSE popoverRect:CGRectZero completion:nil];
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr
{
    [self shareUsingActivityController:text urlStr:urlStr image:nil];
}

-(void)shareUsingActivityController:(NSString *)text
{
    [self shareUsingActivityController:text urlStr:nil];
}

-(void)shareWhatsapp:(NSString *)text urlStr:(NSString *)urlStr
{
    WhatsAppActivity *activity = [[WhatsAppActivity alloc] init];
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    if(text.length>0) {
        [activities addObject:text];
    }
    if(urlStr.length>0) {
        [activities addObject:[NSURL URLWithString:urlStr]];
    }
    [activity prepareWithActivityItems:activities];
}

#pragma mark Email

-(void)mailFailed
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedStringFromTable(@"BGSSAlertEmailFail", @"BGSS_Localizable", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] show];
    [self completeWithResult:SharingResultFailed];
}

-(void)shareEmail:(NSString*)mailBody completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareEmail:nil mailBody:mailBody completion:completion];
}

-(void)shareEmail:(NSString*)mailBody completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController
{
    [self shareEmail:nil mailBody:mailBody completion:completion mailComposeViewController:mailComposeViewController];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareEmail:mailSubject mailBody:mailBody recipients:nil completion:completion];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController
{
    [self shareEmail:mailSubject mailBody:mailBody recipients:nil completion:completion mailComposeViewController:mailComposeViewController];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareEmail:mailSubject mailBody:mailBody recipients:recipients isHTML:FALSE completion:completion];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController
{
    [self shareEmail:mailSubject mailBody:mailBody recipients:recipients isHTML:FALSE completion:completion mailComposeViewController:mailComposeViewController];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareEmail:mailSubject mailBody:mailBody recipients:recipients isHTML:isHTML attachmentData:nil attachmentFileName:nil attachmentMimeType:nil completion:completion];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController
{
    [self shareEmail:mailSubject mailBody:mailBody recipients:recipients isHTML:isHTML attachmentData:nil attachmentFileName:nil attachmentMimeType:nil completion:completion mailComposeViewController:mailComposeViewController];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML attachmentData:(NSData *)attachmentData attachmentFileName:(NSString *)attachmentFileName attachmentMimeType:(NSString *)attachmentMimeType completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareEmail:mailSubject mailBody:mailBody recipients:recipients isHTML:isHTML attachmentData:attachmentData attachmentFileName:attachmentFileName attachmentMimeType:attachmentMimeType completion:completion mailComposeViewController:nil];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML attachmentData:(NSData *)attachmentData attachmentFileName:(NSString *)attachmentFileName attachmentMimeType:(NSString *)attachmentMimeType completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController
{
    self.shareCompleted = completion;
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if(!mailClass) {
        [self mailFailed];
        return;
    }
    
    if(![MFMailComposeViewController canSendMail]) {
        [self mailFailed];
        return;
    }
    
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    [controller setToRecipients:recipients];
    [controller setSubject:mailSubject];
    [controller setMessageBody:mailBody isHTML:isHTML];
    if(attachmentData) {
        [controller addAttachmentData:attachmentData mimeType:attachmentMimeType fileName:attachmentFileName];
    }
    if(mailComposeViewController) {
        mailComposeViewController(controller);
    }
    else {
        UIViewController *presentingController = [self presentingVC];
        [presentingController presentViewController:controller animated:TRUE completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
        }];
        CFRunLoopWakeUp(CFRunLoopGetCurrent());
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissViewControllerAnimated:TRUE completion:^{
        if(result == MFMailComposeResultSent) {
            [self completeWithResult:SharingResultSuccess];
        }
        else if(result == MFMailComposeResultSaved) {
            [self completeWithResult:SharingResultSuccess];
        }
        else if(result == MFMailComposeResultCancelled) {
            [self completeWithResult:SharingResultCancelled];
        }
        else if(result == MFMailComposeResultFailed) {
            [self completeWithResult:SharingResultFailed];
        }
    }];
}

#pragma mark SMS

-(void)smsFailed
{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:NSLocalizedStringFromTable(@"BGSSAlertSMSFail", @"BGSS_Localizable", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] show];
    [self completeWithResult:SharingResultFailed];
}

-(void)shareSMS:(NSString *)message recipient:(NSArray *)recipients completion:(void (^)(SharingResult sharingResult))completion
{
    self.shareCompleted = completion;
    
    Class smsClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if(!smsClass) {
        [self smsFailed];
        return;
    }
    
    if(![MFMessageComposeViewController canSendText]) {
        [self smsFailed];
        return;
    }
    
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
    controller.messageComposeDelegate = self;
    controller.body = message;
    controller.recipients = recipients;
    UIViewController *presentingController = [self presentingVC];
    [presentingController presentViewController:controller animated:TRUE completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle];
    }];
    CFRunLoopWakeUp(CFRunLoopGetCurrent());
}

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	[controller dismissViewControllerAnimated:TRUE completion:^{
        if(result == MessageComposeResultSent) {
            [self completeWithResult:SharingResultSuccess];
        }
        else if(result == MessageComposeResultCancelled) {
            [self completeWithResult:SharingResultCancelled];
        }
        else if(result == MessageComposeResultFailed) {
            [self completeWithResult:SharingResultFailed];
        }
    }];
}

#pragma mark DocumentInterActionController methods

-(void)shareImageUsingDocumentController:(UIImage *)image fileName:(NSString *)fileName completion:(void (^)(UIDocumentInteractionController *documentInteractionController))completion
{
    self.documentInteractionController = nil;
    _documentInteractionController = [[UIDocumentInteractionController alloc] init];
    NSString *imgPath = [NSString stringWithFormat:@"%@/%@.jpg", [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"], fileName];
    [UIImageJPEGRepresentation(image, 1.0f) writeToFile:imgPath atomically:TRUE];
    self.documentInteractionController.URL = [NSURL fileURLWithPath:imgPath];
    self.documentInteractionController.UTI = @"public.jpeg";
    self.documentInteractionController.delegate = self;
    
    //Presenting
    if(completion) {
        completion(self.documentInteractionController);
    }
}

#pragma mark Address/Maps

-(void)shareAddressInMaps:(NSString *)address
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
        [self shareAddressInGoogleMaps:address];
    }
    else {
        [self shareAddressInAppleMaps:address];
    }
}

-(void)shareAddressInAppleMaps:(NSString *)address
{
    NSString *urlStr = [[NSString stringWithFormat:@"http://maps.apple.com/?q=%@", address] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

-(void)shareAddressInGoogleMaps:(NSString *)address
{
    NSString *urlStr = [[NSString stringWithFormat:@"comgooglemaps://?q=%@", address] stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
}

#pragma mark Sharing Safari

-(void)shareURLWithSafari:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

-(void)shareURLStringWithSafari:(NSString *)urlStr
{
    [self shareURLWithSafari:[NSURL URLWithString:urlStr]];
}

#pragma mark Completion Block

-(void)completeWithResult:(SharingResult)sharingResult
{
    if(self.shareCompleted) {
        self.shareCompleted(sharingResult);
    }
}

#pragma mark Presenting ViewControllers

-(UIViewController *)presentingVC
{
    if(self.presentingViewController) {
        return self.presentingViewController;
    }
    NSLog(@"BDGShare: No presenting view controller set, using keyWindow rootViewController");
    return [[[UIApplication sharedApplication] keyWindow] rootViewController];
}

#pragma mark Singleton

+(id)sharedBDGShare
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

@end






































