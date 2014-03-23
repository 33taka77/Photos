//
//  FlickrMngr.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/23.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "FlickrMngr.h"
#import "FlickrKit.h"

@interface FlickrMngr()
@property (nonatomic, retain) FKDUNetworkOperation* checkAuthOp;
@property (nonatomic, retain) FKDUNetworkOperation* authOp;
@property (nonatomic, retain) FKDUNetworkOperation* completeAuthOp;

@end


@implementation FlickrMngr

static FlickrMngr* g_FlickrMngr = nil;
static bool g_authIsComplete = NO;

+ (FlickrMngr*)sharedFlkckrMngr{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool{
            g_FlickrMngr = [[FlickrMngr alloc] init];
        }
    });
    return g_FlickrMngr;
}

- (void)initialize
{
    NSString *apiKey = @"685147fe878a39bf9b9853ae77b31e0b";
	NSString *secret = @"9e919502e9ceea1f";
    [[FlickrKit sharedFlickrKit] initializeWithAPIKey:apiKey sharedSecret:secret];
}

- (BOOL)loginToFlickr
{
    BOOL isAuth;
    FlickrMngrLoginCmplete completion = ^(BOOL* result, NSString* userId, NSString* userName){
        
    };
    isAuth = [self ckeckAuth:completion isSync:YES];
    if( isAuth == NO )
    {
        [self DoAuth];
    }
    /*
    while (!g_authIsComplete) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    */ 
    isAuth = [[FlickrKit sharedFlickrKit] isAuthorized ];
    return isAuth;
}

- (void)beginWebAuth:(NSString*)callbackURLString load:(FlickrMngrWebAuthLoad)callbackForLoad
{
    self.authOp = [[FlickrKit sharedFlickrKit] beginAuthWithCallbackURL:[NSURL URLWithString:callbackURLString] permission:FKPermissionDelete completion:^(NSURL *flickrLoginPageURL, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
				NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:flickrLoginPageURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
				callbackForLoad(urlRequest);//[self.webView loadRequest:urlRequest];
			} else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
                g_authIsComplete = YES;
			}
        });
	}];
}

- (void)cancelAuthOperation
{
    [self.authOp cancel];
    [self.checkAuthOp cancel];
    [self.completeAuthOp cancel];
}

- (void)authCallback:(NSURL*)callbackUrl callback:(FlickrMngrWebAuthCallback)callback
{
    self.completeAuthOp = [[FlickrKit sharedFlickrKit] completeAuthWithURL:callbackUrl completion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
                self.userID = userId;
                self.userName = userName;
                if(callback != nil )
                    callback( userId, userName );
            } else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
				[alert show];
			}
            g_authIsComplete = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UserAuthComplete" object:self userInfo:nil];
        });
	}];

}
// ----- local functions ------------------------------------------------------------------

- (BOOL)ckeckAuth:(FlickrMngrLoginCmplete)completon isSync:(BOOL)isSync
{
    __block BOOL result = NO;
    __block BOOL pass = NO;
    self.checkAuthOp = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
                self.userID = userId;
                self.userName = userName;
                result = YES;
                pass = YES;
                completon(&result, userId, userName);
			} else {
				self.userID = nil;
                self.userName = nil;
                result = NO;
                pass = YES;
                completon(&result, userId, userName);
			}
        });
	}];
    if( isSync == YES )
    {
        while( pass != YES ){
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
        }
    }
    return result;
}

- (void)DoAuth
{
    if (![FlickrKit sharedFlickrKit].isAuthorized) {
        //AuthViewController *authView = [[AuthViewController alloc] init];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserAuthStart" object:nil userInfo:nil];
        //AuthViewController* authView = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
        //[self.navigationController pushViewController:authView animated:YES];
    }
}



@end
