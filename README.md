BDGShare
========

Great lightweight sharing wrapper using built-in facebook, twitter, whatsapp, email, text message, activitycontroller, documentinteractioncontroller, all with 1 line and great completion blocks!

## Installation using CocoaPods
```
pod 'BDGShare'
```

## Usage

**Facebook**
```
[BDGSharing shareFacebook:@"text" urlStr:@"url string" image:nil completion:^(SharingResult sharingResult) {        
}];
```

**Twitter**
```
[BDGSharing shareTwitter:@"text" urlStr:@"url string" image:nil completion:^(SharingResult sharingResult) {        
}];
```

**Whatsapp**
```
[BDGSharing shareWhatsapp:@"Text message" urlStr:@"Optional url string"];
```

**Email**
```
[BDGSharing shareEmail:@"Subject" mailBody:@"Body" recipients:nil isHTML:FALSE completion:^(SharingResult sharingResult) {        
}];
```

**Text message/SMS**
```
[BDGSharing shareSMS:@"Text message" recipient:nil completion:^(SharingResult sharingResult) {        
}];
```

**Activity Controller (including optional whatsapp as an activity, also just updated to support iOS8 iPad new presentation popover)**
```
[BDGSharing shareUsingActivityController:@"Text" urlStr:@"Url str" image:nil whatsapp:TRUE];
```

**Document Interaction Controller)**
```
[BDGSharing shareImageUsingDocumentController:image fileName:@"ImageToShareName" completion:^(UIDocumentInteractionController *documentInteractionController) {        
}];
```

### Additional options<br/>
@property: presentingViewController. If not set, it uses the [UIApplication sharedApplication] keyWindow's rootViewController<br/>
@property: excludedActivities. You can use this property to define activities the activityController should exclude. By default some rarely used activities are excluded.<br/>


### Sharing results<br/>
The completion blocks return a sharingresult which is always one of the following:<br/>
SharingResultFailed<br/>
SharingResultCancelled<br/>
SharingResultSuccess<br/>