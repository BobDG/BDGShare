BDGShare
========

Great lightweight sharing wrapper using built-in facebook, twitter, whatsapp, email, text message, activitycontroller, documentinteractioncontroller, all with 1 line and great completion blocks!

## Installation using Cocoapods
```
pod 'BDGShare'
```

## Usage

**Facebook**
```
[[BDGShare sharedBDGShare] shareFacebook:@"text" urlStr:@"url string" image:nil completion:^(SharingResult sharingResult) {        
}];
```

**Twitter**
```
[[BDGShare sharedBDGShare] shareTwitter:@"text" urlStr:@"url string" image:nil completion:^(SharingResult sharingResult) {        
}];
```

**Whatsapp**
```
[[BDGShare sharedBDGShare] shareWhatsapp:@"Text message" urlStr:@"Optional url string"];
```

**Email**
```
[[BDGShare sharedBDGShare] shareEmail:@"Subject" mailBody:@"Body" recipients:nil isHTML:FALSE completion:^(SharingResult sharingResult) {        
}];
```

**Text message/SMS**
```
[[BDGShare sharedBDGShare] shareSMS:@"Text message" recipient:nil completion:^(SharingResult sharingResult) {        
}];
```

**Activity Controller (including optional whatsapp as an activity)**
```
[[BDGShare sharedBDGShare] shareUsingActivityController:@"Text" urlStr:@"Url str" image:nil whatsapp:TRUE];
```

**Document Interaction Controller)**
```
[[BDGShare sharedBDGShare] shareImageUsingDocumentController:image fileName:@"ImageToShareName" completion:^(UIDocumentInteractionController *documentInteractionController) {        
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