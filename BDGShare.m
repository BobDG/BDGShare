//
//  BDGShare.m
//
//  Created by Bob de Graaf on 09-10-14.
//  Copyright (c) 2014 GraafICT. All rights reserved.
//

#import <Social/Social.h>
#import <MessageUI/MessageUI.h>

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
    [presentingController presentViewController:controller animated:TRUE completion:nil];
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

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image whatsapp:(BOOL)whatsapp popoverRect:(CGRect)popoverRect
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
    [controller setCompletionHandler:^(NSString *activityType, BOOL completed) {
        [self completeWithResult:completed ?  SharingResultSuccess : SharingResultFailed];
    }];
    
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
    [presentingController presentViewController:controller animated:TRUE completion:nil];
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image whatsapp:(BOOL)whatsapp
{
    [self shareUsingActivityController:text urlStr:urlStr image:image whatsapp:whatsapp popoverRect:CGRectZero];
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image popoverRect:(CGRect)popoverRect
{
    [self shareUsingActivityController:text urlStr:urlStr image:image whatsapp:FALSE popoverRect:popoverRect];
}

-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image
{
    [self shareUsingActivityController:text urlStr:urlStr image:image whatsapp:FALSE popoverRect:CGRectZero];
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

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML completion:(void (^)(SharingResult sharingResult))completion
{
    [self shareEmail:mailSubject mailBody:mailBody recipients:recipients isHTML:isHTML attachmentData:nil attachmentFileName:nil attachmentMimeType:nil completion:completion];
}

-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML attachmentData:(NSData *)attachmentData attachmentFileName:(NSString *)attachmentFileName attachmentMimeType:(NSString *)attachmentMimeType completion:(void (^)(SharingResult sharingResult))completion
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
    UIViewController *presentingController = [self presentingVC];
    [presentingController presentViewController:controller animated:TRUE completion:nil];
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
    [presentingController presentViewController:controller animated:TRUE completion:nil];
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






































