//
//  FlickrMngr.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/23.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^FlickrMngrLoginCmplete)(BOOL *status, NSString* userId, NSString *fullName);
typedef void (^FlickrMngrWebAuthLoad)(NSMutableURLRequest* requestURL);
typedef void (^FlickrMngrWebAuthCallback)(NSString* userId, NSString* userName);

@interface FlickrMngr : NSObject
@property (nonatomic, retain) NSString* userID;
@property (nonatomic, retain) NSString* userName;

+ (FlickrMngr*)sharedFlkckrMngr;
- (void)initialize;
- (BOOL)loginToFlickr;
- (void)beginWebAuth:(NSString*)callbackURLString load:(FlickrMngrWebAuthLoad)callbackForLoad;
- (void)cancelAuthOperation;
- (void)authCallback:(NSURL*)callbackUrl callback:(FlickrMngrWebAuthCallback)callback;

@end
