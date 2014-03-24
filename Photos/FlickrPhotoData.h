//
//  FlickrPhotoData.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/24.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrPhotoData : NSObject
@property (nonatomic, retain) NSURL* m_thumbnailUrl;
@property (nonatomic, retain) NSMutableDictionary* m_photoData;
@property (nonatomic, retain) NSMutableDictionary* m_exifData;
@end
