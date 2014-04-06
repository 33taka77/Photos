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
@property (nonatomic, retain) FKDUNetworkOperation* myPhotostreamOp;
@property (nonatomic, retain) FKDUNetworkOperation* exifOp;
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

- (void)loginToFlickr:(FlickrMngrLoginCmplete)completion
{
    [self ckeckAuth:completion isSync:NO];
    //[self DoAuth];
}

- (void)retryAuth
{
    if (![FlickrKit sharedFlickrKit].isAuthorized) {
        //AuthViewController *authView = [[AuthViewController alloc] init];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UserAuthStart" object:nil userInfo:nil];
        //AuthViewController* authView = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
        //[self.navigationController pushViewController:authView animated:YES];
    }
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
    [self.myPhotostreamOp cancel];
    [self.exifOp cancel];
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

const NSInteger cNumOfLoadPhotosAtonece = 20;
- (BOOL)getPhotoList:(FlickrMngrPhotoGetStreamComplete)completion
{
    BOOL result = YES;
    __block NSMutableArray* returnPhotosArray = [[NSMutableArray alloc] init];
    if ([FlickrKit sharedFlickrKit].isAuthorized) {
        __block NSInteger page = 1;
        __block BOOL isFinish = NO;
        __block BOOL pass = YES;
        __block NSInteger num = 0;
        while(!isFinish){
            if( pass == YES ){
                self.myPhotostreamOp = [[FlickrKit sharedFlickrKit] call:@"flickr.photos.search" args:@{@"user_id": self.userID, @"per_page": [NSString stringWithFormat:@"%d",cNumOfLoadPhotosAtonece], @"page": [NSString stringWithFormat:@"%d", page]} maxCacheAge:FKDUMaxAgeNeverCache completion:^(NSDictionary *response, NSError *error) {
//                  dispatch_async(dispatch_get_main_queue(), ^{
                        if (response) {
                            NSArray* getPhotos = [response valueForKeyPath:@"photos.photo"];
                            [returnPhotosArray addObjectsFromArray:getPhotos];
                            num = num + getPhotos.count;
                            if( getPhotos.count < cNumOfLoadPhotosAtonece )
                            {
                                completion( returnPhotosArray );
                                NSLog(@"found photo are %d.",num);
                                isFinish = YES;
                            }
                            page++;
                            pass = YES;
                        } else {
                            NSLog(@"getPhotoList error");
                            isFinish = YES;
                        }
//                  });
                }];
                pass = NO;
            }

        }
    }else{
        result = NO;
    }
    return result;
}

- (NSURL*)makePhotoURLBySize:(FlickrMngrPhotoSize)size photoData:(NSDictionary*)photo
{
    FKPhotoSize sizeOfImage;
    switch (size) {
        case FMPhotoSizeUnknown:
            sizeOfImage = FKPhotoSizeUnknown;
            break;
        case FMPhotoSizeCollectionIconLarge:
            sizeOfImage = FKPhotoSizeCollectionIconLarge;
            break;
        case FMPhotoSizeBuddyIcon:
            sizeOfImage = FKPhotoSizeBuddyIcon;
            break;
        case FMPhotoSizeSmallSquare75:
            sizeOfImage = FKPhotoSizeSmallSquare75;
            break;
        case FMPhotoSizeLargeSquare150:
            sizeOfImage = FKPhotoSizeLargeSquare150;
            break;
        case FMPhotoSizeThumbnail100:
            sizeOfImage = FKPhotoSizeThumbnail100;
            break;
        case FMPhotoSizeSmall240:
            sizeOfImage = FKPhotoSizeSmall240;
            break;
        case FMPhotoSizeSmall320:
            sizeOfImage = FKPhotoSizeSmall320;
            break;
        case FMPhotoSizeMedium500:
            sizeOfImage = FKPhotoSizeMedium500;
            break;
        case FMPhotoSizeMedium640:
            sizeOfImage = FKPhotoSizeMedium640;
            break;
        case FMPhotoSizeMedium800:
            sizeOfImage = FKPhotoSizeMedium800;
            break;
        case FMPhotoSizeLarge1024:
            sizeOfImage = FKPhotoSizeLarge1024;
            break;
        case FMPhotoSizeLarge1600:
            sizeOfImage = FKPhotoSizeLarge1600;
            break;
        case FMPhotoSizeLarge2048:
            sizeOfImage = FKPhotoSizeLarge2048;
            break;
        case FMPhotoSizeOriginal:
            sizeOfImage = FKPhotoSizeOriginal;
            break;
        case FMPhotoSizeVideoOriginal:
            sizeOfImage = FKPhotoSizeVideoOriginal;
            break;
        case FMPhotoSizeVideoHDMP4:
            sizeOfImage = FKPhotoSizeVideoHDMP4;
            break;
        case FMPhotoSizeVideoSiteMP4:
            sizeOfImage = FKPhotoSizeVideoSiteMP4;
            break;
        case FMPhotoSizeVideoMobileMP4:
            sizeOfImage = FKPhotoSizeVideoMobileMP4;
            break;
        case FMPhotoSizeVideoPlayer:
            sizeOfImage = FKPhotoSizeVideoPlayer;
            break;
            
        default:
            break;
    }
    NSURL *url = [[FlickrKit sharedFlickrKit] photoURLForSize:sizeOfImage fromPhotoDictionary:photo];
    return url;
}

- (void)getPhotoData:(NSURL*)url completion:(FlickrMngrGetPhotoDataComplete)completion
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        UIImage *image = [[UIImage alloc] initWithData:data];
        completion( image );
    }];
}

- (void)getExifData:(NSDictionary*)photo completion:(FlickrMngrGetExifDataComplete)completion
{
    FKFlickrPhotosGetExif *exif = [[FKFlickrPhotosGetExif alloc] init];
    NSString* idNumberString = [photo valueForKey:@"id"];
    exif.photo_id = idNumberString;
    self.exifOp = [[FlickrKit sharedFlickrKit] call:exif completion:^(NSDictionary *response, NSError *error) {
        if (response) {
            NSArray* getExifDataArray = [response valueForKeyPath:@"photo.exif"];
            NSMutableDictionary* returnDictionary = [[NSMutableDictionary alloc] init];
            for( NSDictionary* exifItem in getExifDataArray )
            {
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"Make"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"Maker"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"Model"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"Model"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"Orientation"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"Orientation"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"Artist"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"Artist"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"ExposureTime"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"ExposureTime"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"FNumber"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"FNumber"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"ISO"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"ISO"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"DateTimeOriginal"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"DateTimeOriginal"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"ExposureCompensation"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"ExposureCompensation"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"MaxApertureValue"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"MaxApertureValue"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"Flash"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"Flash"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"FocalLength"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"FocalLength"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"LensInfo"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"LensInfo"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"LensModel"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"LensModel"];continue;}
                if( [[exifItem valueForKey:@"tag"] isEqualToString:@"Lens"] ){
                    [returnDictionary setObject:[[exifItem valueForKey:@"raw"] valueForKey:@"_content"] forKey:@"Lens"];}
            }
            completion( returnDictionary );
        }
    }];

}

// ----- local functions ------------------------------------------------------------------

- (BOOL)ckeckAuth:(FlickrMngrLoginCmplete)completon isSync:(BOOL)isSync
{
    __block BOOL result = NO;
    __block BOOL pass = NO;
    //return YES;
    self.checkAuthOp = [[FlickrKit sharedFlickrKit] checkAuthorizationOnCompletion:^(NSString *userName, NSString *userId, NSString *fullName, NSError *error) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (!error) {
                self.userID = userId;
                self.userName = userName;
                result = YES;
                pass = YES;
                if( completon != nil )
                    completon(result, userId, userName);
			} else {
				self.userID = nil;
                self.userName = nil;
                result = NO;
                pass = YES;
                if( completon != nil )
                    completon(result, userId, userName);
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




@end
