//
//  FlickrMngr.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/23.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FMPhotoSizeUnknown = 0,
    FMPhotoSizeCollectionIconLarge,
    FMPhotoSizeBuddyIcon,
	FMPhotoSizeSmallSquare75,
    FMPhotoSizeLargeSquare150,
	FMPhotoSizeThumbnail100,
	FMPhotoSizeSmall240,
    FMPhotoSizeSmall320,
    FMPhotoSizeMedium500,
    FMPhotoSizeMedium640,
    FMPhotoSizeMedium800,
    FMPhotoSizeLarge1024,
    FMPhotoSizeLarge1600,
    FMPhotoSizeLarge2048,
    FMPhotoSizeOriginal,
    FMPhotoSizeVideoOriginal,
    FMPhotoSizeVideoHDMP4,
    FMPhotoSizeVideoSiteMP4,
    FMPhotoSizeVideoMobileMP4,
    FMPhotoSizeVideoPlayer,
} FlickrMngrPhotoSize;

typedef void (^FlickrMngrLoginCmplete)(BOOL status, NSString* userId, NSString *fullName);
typedef void (^FlickrMngrWebAuthLoad)(NSMutableURLRequest* requestURL);
typedef void (^FlickrMngrWebAuthCallback)(NSString* userId, NSString* userName);
typedef void (^FlickrMngrPhotoGetStreamComplete)(NSArray* photos);
typedef void (^FlickrMngrGetPhotoDataComplete)(UIImage* photoData);
typedef void (^FlickrMngrGetExifDataComplete)(NSDictionary* exifData);

@interface FlickrMngr : NSObject
@property (nonatomic, retain) NSString* userID;
@property (nonatomic, retain) NSString* userName;

+ (FlickrMngr*)sharedFlkckrMngr;
- (void)initialize;
- (void)loginToFlickr:(FlickrMngrLoginCmplete)completion;
- (void)retryAuth;
- (void)beginWebAuth:(NSString*)callbackURLString load:(FlickrMngrWebAuthLoad)callbackForLoad;
- (void)cancelAuthOperation;
- (void)authCallback:(NSURL*)callbackUrl callback:(FlickrMngrWebAuthCallback)callback;
- (BOOL)getPhotoList:(FlickrMngrPhotoGetStreamComplete)completion;
- (void)getPhotoData:(NSURL*)url completion:(FlickrMngrGetPhotoDataComplete)completion;
- (NSURL*)makePhotoURLBySize:(FlickrMngrPhotoSize)size photoData:(NSDictionary*)photo;
- (void)getExifData:(NSDictionary*)photo completion:(FlickrMngrGetExifDataComplete)completion;


@end
