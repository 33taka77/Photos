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
    NSMutableArray* m_groupDatas; /* array of SectionData */
    AssetMngr* m_assetMngr;
}
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
            if( m_groupDatas != nil )
            {
                m_groupDatas = [[NSMutableArray alloc] init];
            }
        }
}

- (void) createSectionDataAndSortByDate
{
    if( m_isLocal )
    {
        NSArray* groupNames = [m_assetMngr GetGroupNames];
        for( NSString* name in groupNames )
        {
            for( SectionData* data in m_groupDatas )
            {
                if( data.sectionTitle == name )
                    return;
            }
            SectionData* section = [[SectionData alloc] initWithTitle:name];
            section.kind = kImageLibraryTypeLocal;
            NSArray* array = [m_assetMngr buildSectionsForDateWithGroupName:name];
            section.items = [array mutableCopy];
            [m_groupDatas addObject:section];
        }
    }
}

- (NSInteger)getSectionCount
{
    return m_groupDatas.count;
}

- (NSArray*)getSectionNames
{
    if( m_isLocal )
    {
        return [m_assetMngr GetGroupNames];
    }
    return nil;
}

- (NSInteger)getNumOfImagesInSection:(NSString*)sectionName
{
    NSInteger count = 0;
    for( SectionData* section in m_groupDatas )
    {
        if( [section.sectionTitle isEqual:sectionName] )
        {
            count = section.items.count;
            break;
        }
    }
    return count;
}

- (UIImage*)getThumbnailAtSectionName:(NSString*)sectionName index:(NSInteger)index
{
    UIImage* image;
    for( SectionData* section in m_groupDatas )
    {
        if( [section.sectionTitle isEqual:sectionName] )
        {
            if( section.kind == kImageLibraryTypeLocal )
            {
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
    for( SectionData* section in m_groupDatas )
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


@end
