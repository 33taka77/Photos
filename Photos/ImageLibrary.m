//
//  ImageLibrary.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/06.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import "ImageLibrary.h"
#import "AssetMngr.h"

@interface ImageLibrary () <AssetLibraryDelegate>
{
    BOOL m_isLocal;
    BOOL m_isFlickr;
    BOOL m_Facebook;
    NSMutableArray* m_sectionDatas; /* array of SectionData */
    AssetMngr* m_assetMngr;
}
@property NSInteger m_currentGroup;

@end


@implementation ImageLibrary

    static ImageLibrary* g_Library;

- (void)updateView
{
    [self.delegate updateView];
}

+ (ImageLibrary*)sharedLibrary:(NSUInteger)type
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_Library = [[ImageLibrary alloc] init];
    });
    [g_Library setWithType:type];
    return g_Library;
}

-(void)initializeLibrary
{
    m_assetMngr.delegate = self;
}


- (void)setCurrentGroup:(NSInteger)index
{
    self.m_currentGroup = index;
}

-(NSInteger)getCurrentGroupIndex
{
    return self.m_currentGroup;
}


- (void)setWithType:(NSUInteger)type
{
        switch (type) {
            case (kImageLibraryTypeLocal):
                m_isLocal = YES;
                m_isFlickr = NO;
                m_Facebook = NO;
                break;
            case (kImageLibraryTypeFlickr):
                m_isLocal = NO;
                m_isFlickr = YES;
                m_Facebook = NO;
                break;
            case (kImageLibraryTypeFacebook):
                m_isLocal = NO;
                m_isFlickr = NO;
                m_Facebook = YES;
                break;
            case (kImageLibraryTypeLocal|kImageLibraryTypeFlickr):
                m_isLocal = YES;
                m_isFlickr = YES;
                m_Facebook = NO;
                break;
            case (kImageLibraryTypeLocal|kImageLibraryTypeFacebook):
                m_isLocal = YES;
                m_isFlickr = NO;
                m_Facebook = YES;
                break;
            case (kImageLibraryTypeFlickr|kImageLibraryTypeFacebook):
                m_isLocal = NO;
                m_isFlickr = YES;
                m_Facebook = YES;
                break;
            case (kImageLibraryTypeLocal|kImageLibraryTypeFlickr|kImageLibraryTypeFacebook):
                m_isLocal = YES;
                m_isFlickr = YES;
                m_Facebook = YES;
                break;
                
            default:
                break;
        }
        if( m_isLocal )
        {
            m_assetMngr = [AssetMngr create];
            [m_assetMngr initializeALAssetLibrary];
            [m_assetMngr buildAssetData];
            if( m_sectionDatas == nil )
            {
                m_sectionDatas = [[NSMutableArray alloc] init];
            }
        }
}

-(void)createSectionEntries
{
    if( m_isLocal )
    {
        NSArray* groupNames = [m_assetMngr GetGroupNames];
        BOOL skipToNext = NO;
        for( NSString* name in groupNames )
        {
            for( SectionData* data in m_sectionDatas )
            {
                if( data.sectionTitle == name )
                {
                    skipToNext = YES;
                    break;
                }
            }
            if( skipToNext == NO )
            {
                SectionData* section = [[SectionData alloc] initWithTitle:name];
                section.kind = kImageLibraryTypeLocal;
                //NSArray* array = [m_assetMngr buildSectionsForDateWithGroupName:name];
                //section.items = [array mutableCopy];
                [m_sectionDatas addObject:section];
            }
            skipToNext = NO;
        }
    }
}

- (void)createSectionDataAndSortByDate
{
    if( m_isLocal )
    {
        NSArray* groupNames = [m_assetMngr GetGroupNames];
        BOOL skipToNext = NO;
        for( NSString* name in groupNames )
        {
            for( SectionData* data in m_sectionDatas )
            {
                if( data.sectionTitle == name )
                {
                    skipToNext = YES;
                    break;
                }
            }
            if( skipToNext == NO )
            {
                //SectionData* section = [[SectionData alloc] initWithTitle:name];
                //section.kind = kImageLibraryTypeLocal;
                NSArray* array = [m_assetMngr buildSectionsForDateWithGroupName:name kind:kImageLibraryTypeLocal];
                //section.items = [array mutableCopy];
                [m_sectionDatas addObjectsFromArray:array];
            }
            skipToNext = NO;
        }
    }
}


- (void)createSectionDataAndSortByDateAtGroup:(NSInteger)GroupIndex
{
    if( m_isLocal )
    {
        NSArray* groupNames = [m_assetMngr GetGroupNames];
        NSString* name = groupNames[GroupIndex];
        //SectionData* section = [[SectionData alloc] initWithTitle:name];
        //section.kind = kImageLibraryTypeLocal;
        NSArray* array = [m_assetMngr buildSectionsForDateWithGroupName:name kind:kImageLibraryTypeLocal];
        //section.items = [array mutableCopy];
        [m_sectionDatas addObjectsFromArray:array];
    }
}

- (NSInteger)getGroupCount
{
    NSArray* groupArray = [m_assetMngr GetGroupNames];
    return groupArray.count;
}

- (NSInteger)getSectionCount
{
    return m_sectionDatas.count;
}

- (NSArray*)getGroupNames
{
    if( m_isLocal )
    {
        return [m_assetMngr GetGroupNames];
    }
    return nil;
}

- (NSArray*)getSectionNames
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for( SectionData* section in m_sectionDatas )
    {
        [array addObject:section.sectionTitle];
    }
    return array;
}

- (NSString*)getSectonNameAtGroup:(NSString*)groupName index:(NSInteger)index
{
    return [m_assetMngr GetGroupNames][index];
}

- (NSString*)getGroupNameAtIndex:(NSInteger)index
{
    return [m_assetMngr GetGroupNames][index];
}

- (NSInteger)getNumOfImagesInGroup:(NSString*)groupName
{
    return [m_assetMngr GetCountOfImagesInGroup:groupName];
}

- (NSInteger)getNumOfImagesInSection:(NSString*)sectionName
{
    NSInteger count = 0;
    for( SectionData* section in m_sectionDatas )
    {
        if( [section.sectionTitle isEqual:sectionName] )
        {
            //count = section.items.count;
            count = [m_assetMngr GetCountOfImagesInGroup:sectionName];
            break;
        }
    }
    return count;
}

- (UIImage*)getThumbnailAtGroupName:(NSString*)groupName index:(NSInteger)index
{
    UIImage* image = [m_assetMngr getThumbnailByGroupName:groupName index:index];
    return image;
}

- (UIImage*)getThumbnailAtSectionName:(NSString*)sectionName index:(NSInteger)index
{
    UIImage* image;
    for( SectionData* section in m_sectionDatas )
    {
        if( [section.sectionTitle isEqual:sectionName] )
        {
            if( section.kind == kImageLibraryTypeLocal )
            {
                NSInteger num = section.items.count;
                if( num < index+1 )
                {
                    NSLog(@"error");
                    break;
                }
                NSURL* url = section.items[index];
                image = [m_assetMngr getThumbnail:url];
            }
            break;
        }
    }
    return image;
}

- (UIImage*)getFullViewImageAtSectionName:(NSString*)sectionName index:(NSInteger)index
{
    UIImage* image;
    for( SectionData* section in m_sectionDatas )
    {
        if( [section.sectionTitle isEqual:sectionName] )
        {
            if( section.kind == kImageLibraryTypeLocal )
            {
                NSURL* url = section.items[index];
                image = [m_assetMngr getFullImage:url];
            }
            break;
        }
    }
    return image;
}

- (void)cleanupSectionsData
{
    for( SectionData* section in m_sectionDatas )
    {
        [section.items removeAllObjects];
        section.items = nil;
    }
    [m_sectionDatas removeAllObjects];
    //m_sectionDatas = nil;
}


@end
