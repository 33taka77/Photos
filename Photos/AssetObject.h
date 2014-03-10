//
//  AssetObject.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/10.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssetObject : NSObject
@property (nonatomic, retain) NSURL* m_groupURL;
@property (nonatomic, retain) NSMutableArray* m_items; /* array of NSURL */
@end
