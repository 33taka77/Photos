//
//  ImageLibrary.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/06.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import "ImageLibrary.h"
#import "AssetManager.h"
#import "AssetObject.h"
#import "SectionData.h"

@interface ImageLibrary () <AssetLibraryDelegate>
{
    BOOL m_isLocal;
    BOOL m_isFlickr;
    BOOL m_Facebook;
    AssetManager* m_assetMngr;
}
@property NSInteger m_currentGroup;
@property (nonatomic, retain) NSMutableArray* m_sectionDatas; /* array of SectionData */
@property (nonatomic, retain) NSMutableArray* m_assetGroups; /* array of AssetObject */

@end


@implementation ImageLibrary

    static ImageLibrary* g_Library;

/*
- (void)updateView
{
    [self.delegate updateView];
}
*/

+ (ImageLibrary*)sharedLibrary:(NSUInteger)type
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_Library = [[ImageLibrary alloc] init];
    });
    [g_Library setWithType:type];
    return g_Library;
}

- (void)updateGroupDataGroupURL:(NSURL*)groupUrl
{
    NSLog(@"- (void)updateGroupDataGroupURL:(NSURL*)groupUrl is called");
    [self.delegate updateView];
}

- (void)updateItemDataItemURL:(NSURL*)url groupURL:(NSURL*)groupUrl
{
    BOOL newGroup = YES;
    for( AssetObject* group in self.m_assetGroups )
    {
        if( group.m_groupURL == groupUrl )
        {
            [group.m_items addObject:url];
            newGroup = NO;
            break;
        }
    }
    if( newGroup == YES )
    {
        AssetObject* newGroup = [[AssetObject alloc] init];
        newGroup.m_groupURL = groupUrl;
        newGroup.m_items = [[NSMutableArray alloc] init];
        [newGroup.m_items addObject:url];
        [self.m_assetGroups addObject:newGroup];
    }
}

-(void)initializeLibrary
{
    m_assetMngr.delegate = self;
    self.m_assetGroups = [[NSMutableArray alloc] init];
    
    m_assetMngr = [AssetManager sharedAssetManager];
    [m_assetMngr setAssetManagerModeIsHoldItemData:NO];
    [m_assetMngr enumeAssetItems];

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
}

- (void)createSectionDataAndSortByDateAtGroup:(NSInteger)groupIndex
{
    if( m_isLocal )
    {
        AssetObject* assetObject = self.m_assetGroups[groupIndex];
        
        for( NSURL* url in assetObject.m_items )
        {
            NSDate* date = [m_assetMngr getCaptureDateByURL:url];
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy/MM/dd"];
            NSString *strDate = [formatter stringFromDate:date];
            BOOL isNew = YES;
            for( SectionData* sectionData in self.m_sectionDatas )
            {
                if( [strDate isEqualToString:sectionData.sectionTitle] )
                {
                    [sectionData.items addObject:url];
                    isNew = NO;
                    break;
                }
            }
            if( isNew == YES )
            {
                SectionData* newSection = [[SectionData alloc] init];
                newSection.sectionTitle = strDate;
                newSection.items = [[NSMutableArray alloc] init];
                [newSection.items addObject:url];
            }
        }
    }
}

- (NSInteger)getGroupCount
{
    NSArray* groupArray = [m_assetMngr getGroupNames];
    return groupArray.count;
}

- (NSInteger)getSectionCount
{
    return self.m_sectionDatas.count;
}

- (NSArray*)getGroupNames
{
    if( m_isLocal )
    {
        return [m_assetMngr getGroupNames];
    }
    return nil;
}

- (NSArray*)getSectionNames
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for( SectionData* section in self.m_sectionDatas )
    {
        [array addObject:section.sectionTitle];
    }
    return array;
}

- (NSString*)getSectonNameAtGroup:(NSString*)groupName index:(NSInteger)index
{
    return [m_assetMngr getGroupNames][index];
}

- (NSString*)getGroupNameAtIndex:(NSInteger)index
{
    return [m_assetMngr getGroupNames][index];
}

- (NSInteger)getNumOfImagesInGroup:(NSString*)groupName
{
    return [m_assetMngr getCountOfImagesInGroup:groupName];
}

- (NSInteger)getNumOfImagesInSection:(NSString*)sectionName
{
    NSInteger count = 0;
    for( SectionData* section in self.m_sectionDatas )
    {
        if( [section.sectionTitle isEqual:sectionName] )
        {
            count = section.items.count;
            //count = [m_assetMngr GetCountOfImagesInGroup:sectionName];
            break;
        }
    }
    return count;
}

- (NSArray*)getItemsInSectionByIndex:(NSInteger)sectionIndex
{
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    return sectionData.items;
}
/*
- (NSArray*)getItemsInSection:(NSString*)sectionName
{
    NSArray* array;
    for( SectionData* section in self.m_sectionDatas )
    {
        if( [section.sectionTitle isEqual:sectionName] )
        {
            array = section.items;
            //count = [m_assetMngr GetCountOfImagesInGroup:sectionName];
            break;
        }
    }
    return array;
}
*/
- (UIImage*)getThumbnailAtGroupByIndex:(NSInteger)groupIndex index:(NSInteger)index
{
    AssetObject* assetObj = self.m_assetGroups[groupIndex];
    return [m_assetMngr getThumbnail:assetObj.m_items[index]];
}
/*
- (UIImage*)getThumbnailAtGroupName:(NSString*)groupName index:(NSInteger)index
{
    for( AssetObject* assetObj in self.m_assetGroups )
    {
        m_assetMngr  assetObj.m_groupURL
    UIImage* image = [m_assetMngr getThumbnailByGroupName:groupName index:index];
    return image;
}
*/
- (UIImage*)getThumbnailAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index
{
    SectionData* sectionData = self.m_assetGroups[sectionIndex];
    return [m_assetMngr getThumbnail:sectionData.items[index]];
}

/*
- (UIImage*)getThumbnailAtSectionName:(NSString*)sectionName index:(NSInteger)index
{
    UIImage* image;
    for( SectionData* section in self.m_sectionDatas )
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
*/
- (UIImage*)getFullViewImageAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index
{
    SectionData* sectionData = self.m_assetGroups[sectionIndex];
    return [m_assetMngr getFullImage:sectionData.items[index]];
}
/*
- (UIImage*)getFullViewImageAtSectionName:(NSString*)sectionName index:(NSInteger)index
{
    UIImage* image;
    for( SectionData* section in self.m_sectionDatas )
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
*/
- (void)cleanupSectionsData
{
    for( SectionData* section in self.m_sectionDatas )
    {
        [section.items removeAllObjects];
        section.items = nil;
    }
    [self.m_sectionDatas removeAllObjects];
    //m_sectionDatas = nil;
}


@end
