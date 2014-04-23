//
//  ExifParser.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/04/06.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct{
    unsigned short tag;
    unsigned short type;
    unsigned long count;
    unsigned long offset;
}IFDData;

@interface ExifParser : NSObject

@end
