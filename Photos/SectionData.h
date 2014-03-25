//
//  SectionData.h
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/05.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    SectionKindIsUnknown = 0,
    SectionKindIsLocal,
    SectionKindIsFlickr,
    SectionKindIsFacebook
} KindOfSectionData;

@interface SectionData : NSObject
@property (nonatomic, retain) NSString* sectionTitle;
@property (nonatomic, retain) NSMutableArray* items;
@property  KindOfSectionData kind;

- (id)init;
- (id)initWithTitle:(NSString*)title;


@end
