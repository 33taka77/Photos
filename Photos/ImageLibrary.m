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
#import "FlickrMngr.h"
#import "FlickrPhotoData.h"


@interface ImageLibrary () <AssetLibraryDelegate>
{
    BOOL m_isLocal;
    BOOL m_isFlickr;
    BOOL m_Facebook;
    AssetManager* m_assetMngr;
    FlickrMngr* m_flickrMngr;
}

@property NSInteger m_currentGroup;
@property (nonatomic, retain) NSMutableArray* m_sectionDatas; /* array of SectionData */
@property (nonatomic, retain) NSMutableArray* m_assetGroups; /* array of AssetObject */
@property (nonatomic, retain) NSMutableArray* m_flickrPhotos;

@end


@implementation ImageLibrary


    static ImageLibrary* g_Library;
    static NSString* cFlickrGroupName = @"Flickr:photostream";

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
    self.m_assetGroups = [[NSMutableArray alloc] init];
    self.m_sectionDatas = [[NSMutableArray alloc] init];
    self.m_flickrPhotos = [[NSMutableArray alloc] init];
    
    m_assetMngr = [AssetManager sharedAssetManager];
     [m_assetMngr setAssetManagerModeIsHoldItemData:NO];
    m_assetMngr.delegate = self;
    [m_assetMngr enumeAssetItems];

    m_flickrMngr = [FlickrMngr sharedFlkckrMngr];
    [m_flickrMngr initialize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flickrDataLoad:) name:@"StartFlickrDataLoad" object:nil];
}

- (void)flickrDataLoad:(NSNotification *)notification
{
    [m_flickrMngr getPhotoList:^(NSArray *photos) {
        @autoreleasepool{
            dispatch_async(dispatch_get_main_queue(), ^{
                __block NSInteger count = 0;
                for( NSDictionary* photoData in photos )
                {
                    FlickrPhotoData* data = [[FlickrPhotoData alloc] init];
                    data.m_photoData = [photoData copy];
                    NSURL* url = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeLargeSquare150 photoData:photoData];
                    data.m_thumbnailUrl = url;
                    [m_flickrMngr getExifData:photoData completion:^(NSDictionary *exifData) {
                        data.m_exifData = [exifData copy];
                        [self.m_flickrPhotos addObject:data];
                        count++;
                        if( count == photoData.count )
                        {
                            NSLog(@"===== set exif data ======");
                            [self.delegate updateView];
                        }
                        
                    }];
                }
            });
        }
    }];    
}

- (UIImage*)GetFlickrThumbnailAtGroup:(NSInteger)index
{
    FlickrPhotoData* filkrPhoto = self.m_flickrPhotos[index];
    __block UIImage* image = nil;
    [m_flickrMngr getPhotoData:filkrPhoto.m_thumbnailUrl completion:^(UIImage *photoData) {
        image = photoData;
    }];
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;
}

- (UIImage*)GetFlickrThumbnail:(NSURL*)url
{
    __block UIImage* image = nil;
    [m_flickrMngr getPhotoData:url completion:^(UIImage *photoData) {
        image = photoData;
    }];
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;
}

- (UIImage*)GetFlickrAspectThumbnail:(NSURL*)url
{
    FlickrPhotoData* targetPhoto;
    for( FlickrPhotoData* filkrPhoto in self.m_flickrPhotos ){
        if( filkrPhoto.m_thumbnailUrl == url ){
            targetPhoto = filkrPhoto;
            break;
        }
    }
    __block UIImage* image = nil;
    
    NSURL* targetUrl = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeSmall240 photoData:targetPhoto.m_photoData];
    [m_flickrMngr getPhotoData:targetUrl completion:^(UIImage *photoData) {
        image = photoData;
    }];
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;
}

- (UIImage*)GetFlickrFullSizeImage:(NSURL*)url
{
    FlickrPhotoData* targetPhoto;
    for( FlickrPhotoData* filkrPhoto in self.m_flickrPhotos ){
        if( filkrPhoto.m_thumbnailUrl == url ){
            targetPhoto = filkrPhoto;
            break;
        }
    }
    __block UIImage* image = nil;
    
    NSURL* targetUrl = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeOriginal photoData:targetPhoto.m_photoData];
    [m_flickrMngr getPhotoData:targetUrl completion:^(UIImage *photoData) {
        image = photoData;
    }];
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;

}

- (UIImage*)GetFlickrFullScreenSizeImage:(NSURL*)url
{
    FlickrPhotoData* targetPhoto;
    for( FlickrPhotoData* filkrPhoto in self.m_flickrPhotos ){
        if( filkrPhoto.m_thumbnailUrl == url ){
            targetPhoto = filkrPhoto;
            break;
        }
    }
    __block UIImage* image = nil;
    
    NSURL* targetUrl = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeLarge1024 photoData:targetPhoto.m_photoData];
    [m_flickrMngr getPhotoData:targetUrl completion:^(UIImage *photoData) {
        image = photoData;
    }];
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;
}

- (void)createSectionForFlickr
{
    for( FlickrPhotoData* photo in self.m_flickrPhotos )
    {
        NSDictionary* exifDict = photo.m_exifData;
        NSString* dateTimeString = [exifDict valueForKey:@"DateTimeOriginal"];
        NSArray* separateString = [dateTimeString componentsSeparatedByString:@" "];
        NSString* dateString = separateString[0];
        NSString* sectionDateString = [dateString stringByReplacingOccurrencesOfString:@":" withString:@"/"];
        BOOL isNew = YES;
        for( SectionData* sectionData in self.m_sectionDatas )
        {
            if( [sectionDateString isEqualToString:sectionData.sectionTitle] )
            {
                [sectionData.items addObject:photo.m_thumbnailUrl];
                isNew = NO;
                break;
            }
        }
        if( isNew == YES )
        {
            SectionData* newSection = [[SectionData alloc] init];
            newSection.sectionTitle = sectionDateString;
            newSection.items = [[NSMutableArray alloc] init];
            [newSection.items addObject:photo.m_thumbnailUrl];
            newSection.kind = SectionKindIsFlickr;
            [self.m_sectionDatas addObject:newSection];
        }
    }
    
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
    if( self.m_assetGroups.count == groupIndex )
    {
        if( m_isFlickr )
        {
            [self createSectionForFlickr];
        }
    }else if( m_isLocal )
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
                newSection.kind = SectionKindIsLocal;
                [self.m_sectionDatas addObject:newSection];
            }
        }
    }
}

- (NSInteger)getGroupCount
{
    /*
    NSArray* groupArray = [m_assetMngr getGroupNames];
    return groupArray.count;
    */
    NSInteger num = self.m_assetGroups.count;
    if(m_isFlickr)
    {
        if( self.m_flickrPhotos.count != 0 )
        {
            num++;
        }
    }
    return num;
}

- (NSInteger)getSectionCount
{
    NSInteger num = self.m_sectionDatas.count;
    return self.m_sectionDatas.count;
}

- (NSArray*)getGroupNames
{
    NSMutableArray* retArray = [[NSMutableArray alloc] init];
    if( m_isLocal )
    {
        for( AssetObject* obj in self.m_assetGroups )
        {
            NSString* name = [m_assetMngr getGroupNameByURL:obj.m_groupURL];
            [retArray addObject:name];
        }
    }
    if( m_isFlickr )
    {
        NSString* flickrName = [NSString stringWithString:cFlickrGroupName];
        [retArray addObject:flickrName];
    }
    return retArray;
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

/*
- (NSString*)getSectonNameAtGroup:(NSString*)groupName index:(NSInteger)index
{
    return [m_assetMngr getGroupNames][index];
}
*/
- (NSString*)getGroupNameAtIndex:(NSInteger)index
{
    NSString* str;
    if( index == self.m_assetGroups.count )
    {
        if( m_isFlickr )
        {
            return cFlickrGroupName;
        }
    }
    AssetObject* obj = self.m_assetGroups[index];
    str = [m_assetMngr getGroupNameByURL:obj.m_groupURL];
    return str;
   //return [m_assetMngr getGroupNames][index];
}

- (NSInteger)getNumOfImagesInGroup:(NSString*)groupName
{
    NSInteger num = 0;
    if( [groupName isEqualToString:cFlickrGroupName] )
    {
        if( m_isFlickr )
        {
            num = self.m_flickrPhotos.count;
        }
    }else if( m_isLocal )
    {
        num = [m_assetMngr getCountOfImagesInGroup:groupName];
    }
    
    return num;
}

- (NSInteger)getNumOfImagesInSectionBySectonIndex:(NSInteger)sectionIndex
{
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    NSInteger num = sectionData.items.count;
    return num;
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
    if( self.m_assetGroups.count == groupIndex )
    {
        if( m_isFlickr )
        {
            return [self GetFlickrThumbnailAtGroup:index];
        }
    }else if( m_isLocal )
    {
        AssetObject* assetObj = self.m_assetGroups[groupIndex];
        return [m_assetMngr getThumbnail:assetObj.m_items[index]];
    }
    return nil;
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
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getThumbnail:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrThumbnail:sectionData.items[index]];
    }
    return nil;
}

- (UIImage*)getAspectThumbnailAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index
{
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getThumbnailAspect:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrAspectThumbnail:sectionData.items[index]];
    }
    return nil;
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
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getFullImage:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrFullSizeImage:sectionData.items[index]];
    }
    return nil;
}

- (UIImage*)getFullSreenViewImageAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index
{
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getFullScreenImage:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrFullScreenSizeImage:sectionData.items[index]];
    }
    return nil;
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
