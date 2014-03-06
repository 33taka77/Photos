//
//  SectionData.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/05.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import "SectionData.h"

@interface SectionData ()
@end

@implementation SectionData
- (id)init
{
    self = [super init];
    if( self )
    {
        self.items = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithTitle:(NSString*)title
{
    self = [super init];
    if( self )
    {
        self.items = [[NSMutableArray alloc] init];
        self.sectionTitle = title;
    }
    return self;
}

@end
