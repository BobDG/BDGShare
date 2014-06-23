//
//  BDGShare.h
//
//  Created by Bob de Graaf on 09-10-14.
//  Copyright (c) 2014 GraafICT. All rights reserved.
//

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

/*!
 *  Exclude specific activities for sharing with an activityController, by default are excluded: @[UIActivityTypeAirDrop, UIActivityTypePrint, UIActivityTypeAddToReadingList, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
 */
@property(nonatomic,strong) NSArray *excludeActivities;

/*!
 *  Presenting viewcontroller, the viewcontroller that will present viewcontrollers modally. If not provided, the appdelegate's window.rootViewController will be used.
 */
@property(nonatomic,strong) UIViewController *presentingViewController;

/*!
 *  Share an image using the document controller
 */
-(void)shareImageUsingDocumentController:(UIImage *)image fileName:(NSString *)fileName completion:(void (^)(UIDocumentInteractionController *documentInteractionController))completion;

/*!
 *  Share using the activity controller. All parameters are optional
 
 *  @param whatsapp (include whatsapp as an activity)
 */
-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image;
-(void)shareUsingActivityController:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image whatsapp:(BOOL)whatsapp;

/*!
 *  Share with whatsapp directly
 */
-(void)shareWhatsapp:(NSString *)text urlStr:(NSString *)urlStr;

/*!
 *  Sharing functions, SMS, Twitter, Facebook, Weibo, Email
 */
-(void)shareSMS:(NSString *)message recipient:(NSArray *)recipients completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareTwitter:(NSString *)text urlStr:(NSString *)url image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareFacebook:(NSString *)text urlStr:(NSString *)url image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareWeibo:(NSString *)text urlStr:(NSString *)urlStr image:(UIImage *)image completion:(void (^)(SharingResult sharingResult))completion;
-(void)shareEmail:(NSString*)mailSubject mailBody:(NSString*)mailBody recipients:(NSArray *)recipients isHTML:(BOOL)isHTML completion:(void (^)(SharingResult sharingResult))completion;

@end























