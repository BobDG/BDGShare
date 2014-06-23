//
//  WhatsappActivity.m
//
//  Created by Bob de Graaf on 31-05-14.
//  Copyright (c) 2014 GraafICT. All rights reserved.

#import "WhatsAppActivity.h"

@interface WhatsAppActivity ()

@end


@implementation WhatsAppActivity

-(NSString *)activityType
{
    return @"com.activity.whatsapp";
}

-(UIImage *)activityImage
{
    return [UIImage imageNamed:@"Activity_Whatsapp"];
}

-(NSString *)activityTitle
{
    return @"WhatsApp";
}

-(NSString *)stringByEncodingString:(NSString *)string
{
    CFStringRef encodedString = CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
    return CFBridgingRelease(encodedString);
}

-(BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return TRUE;
}

-(void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSString *text = nil;
    NSString *urlStr = nil;
    for(id activityItem in activityItems) {
        if([activityItem isKindOfClass:[NSString class]]) {
            text = [self stringByEncodingString:activityItem];
        }
        else if([activityItem isKindOfClass:[NSURL class]]) {
            urlStr = [activityItem absoluteString];
        }
    }
    
    NSString *whatsAppURL = @"whatsapp://send?";
    if(text.length>0) {
        whatsAppURL = [whatsAppURL stringByAppendingFormat:@"text=%@", text];
    }
    if(urlStr.length>0) {
        whatsAppURL = [whatsAppURL stringByAppendingFormat:@"%%20Link:%%20%@", urlStr];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:whatsAppURL]];
}

@end






















