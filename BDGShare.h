//
//  BDGShare.h
//
//  Created by Bob de Graaf on 09-10-14.
//  Copyright (c) 2014 GraafICT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, SharingResult) {
    SharingResultFailed,
    SharingResultCancelled,
    SharingResultSuccess,
};

@interface BDGShare : NSObject
{
    
}

+(BDGShare *)sharedBDGShare;

//Shortcut
#define BDGSharing [BDGShare sharedBDGShare]

/*!
 *  Exclude specific activities for sharing with an activityController, by default are excluded: @[UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
 */
@property(nonatomic,strong) NSArray *excludeActivities;

/*!
 *  Presenting viewcontroller, the viewcontroller that will present viewcontrollers modally. If not provided, the appdelegate's window.rootViewController will be used.
 */
@property(nonatomic,strong) UIViewController *presentingViewController;

/*!
 *
 */
@property(nonatomic) UIStatusBarStyle statusBarStyle;

/*!
 *  Share an image using the document controller
 */
-(void)shareImageUsingDocumentController:(UIImage *)image fileName:(NSString *)fileName completion:(void (^)(UIDocumentInteractionController *documentInteractionController))completion;

/*!
 *  Share using the activity controller. All parameters are optional
 
 *  @param whatsapp (include whatsapp as an activity)
 *  @param popoverRect (only for iPad & iOS8, specifiy the sourceRect for the popover activitycontroller)
 */

-(void)shareUsingActivityController:(NSString *)text;
-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr;
-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image;
-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image popoverRect:(CGRect)popoverRect;
-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image whatsapp:(BOOL)whatsapp;
-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image whatsapp:(BOOL)whatsapp popoverRect:(CGRect)popoverRect;
-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image completion:(void (^)(UIActivityViewController *activityViewController))completion;

/*!
 *  Share with whatsapp directly
 */
-(void)shareWhatsapp:(NSString *)text urlStr:(NSString *)urlStr;

/*!
 *  Sharing social media shortcuts: SMS, Twitter, Facebook, Weibo
 */

-(void)shareSMS:(NSString *)message recipient:(NSArray *)recipients completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareTwitter:(NSString *)text urlStr:(NSString *)url image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareFacebook:(NSString *)text urlStr:(NSString *)url image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareWeibo:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion;

/*!
 * Sharing e-mail
 */
-(void)shareEmail:(NSString*)mailBody completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareEmail:(NSString*)mailBody completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML attachmentData:(NSData *)attachmentData attachmentFileName:(NSString *)attachmentFileName attachmentMimeType:(NSString *)attachmentMimeType completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML attachmentData:(NSData *)attachmentData attachmentFileName:(NSString *)attachmentFileName attachmentMimeType:(NSString *)attachmentMimeType completion:(void (^)(SharingResult sharingResult))completion mailComposeViewController:(void(^)(MFMailComposeViewController *mailComposeViewController))mailComposeViewController;

/*!
 *  Address functions, share the address with other Apps? ;)
 */
-(void)shareAddressInMaps:(NSString *)address;
-(void)shareAddressInAppleMaps:(NSString *)address;
-(void)shareAddressInGoogleMaps:(NSString *)address;

/*!
 * Safari function, share the url with Safari? ;)
 */

-(void)shareURLWithSafari:(NSURL *)url;
-(void)shareURLStringWithSafari:(NSString *)urlStr;

@end























