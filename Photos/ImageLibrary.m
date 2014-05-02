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
#import "SQLiteManager.h"


const NSString* cDBFileName = @"ImageInfo.sqlite3";

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

@property (nonatomic, strong) NSMutableArray* fetchResultArray;
@property (nonatomic, strong) NSMutableArray* groupNames;
@property (nonatomic, strong) NSMutableArray* groupArray;
@property NSInteger currentGroupIndex;
@property (nonatomic, strong) NSString* sectionKindString;
@property (nonatomic,strong) NSMutableArray* sections;
@property (nonatomic,strong) NSMutableArray* sectionItems;

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
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"- (void)updateGroupDataGroupURL:(NSURL*)groupUrl is called");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endActivityIndicator"object:nil userInfo:nil];
        [self.delegate updateView];
    });
}

- (void)updateItemDataItemURL:(NSURL*)url groupURL:(NSURL*)groupUrl
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BeginActivityIndicator"object:nil userInfo:nil];
    
    AssetManager* assetManager = [AssetManager sharedAssetManager];
    
    NSDictionary* metaData = [assetManager getMetaDataByURL:url];
    //UIImage* thumbnail = [assetManager getThumbnail:url];
    //UIImage* aspectThumbnail = [assetManager getThumbnailAspect:url];
    
    SQLiteManager* sqlManager = [SQLiteManager sharedSQLiteManager:(NSString*)cDBFileName];
    NSString* select = @"select * from";
    NSString* where = [NSString stringWithFormat:@"where url = '%@' order by sectionDate asc", [url absoluteString]];
    NSMutableArray* arrayOfItem = [self performSelect:select where:where];
    if( arrayOfItem.count != 0 ){
        return;
    }
    
    NSDictionary* objectParam1 = @{@"name":@"DateTimeOriginal", @"type":[NSNumber numberWithInt:TypeReal], @"value":[NSNumber numberWithDouble:[self convertUnixDateTime:[metaData valueForKey:@"DateTimeOriginal"]]] };
    NSDictionary* objectParam2 = @{@"name":@"groupName", @"type":[NSNumber numberWithInt:TypeText], @"value":[assetManager getGroupNameByURL:groupUrl]};
    NSDictionary* objectParam3 = @{@"name":@"sectionDate", @"type":[NSNumber numberWithInt:TypeText], @"value":[self makeShortDateString:[metaData valueForKey:@"DateTimeOriginal"]]};
    NSDictionary* objectParam4 = @{@"name":@"url", @"type":[NSNumber numberWithInt:TypeText], @"value":[url absoluteString]};
    NSDictionary* objectParam5 = @{@"name":@"groupUrl", @"type":[NSNumber numberWithInt:TypeText], @"value":[groupUrl absoluteString]};
    NSDictionary* objectParam6 = @{@"name":@"Model", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Model"]};
    NSDictionary* objectParam7 = @{@"name":@"Maker", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Maker"]};
    
    NSDictionary* objectParam8 = @{@"name":@"ExposureTime", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"ExposureTime"]};
    NSDictionary* objectParam9 = @{@"name":@"FocalLength", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"FocalLength"]};
    NSDictionary* objectParam10 = @{@"name":@"Orientation", @"type":[NSNumber numberWithInt:TypeInteger], @"value":[self cnvertNumber: [metaData valueForKey:@"Orientation"]]};
    NSDictionary* objectParam11 = @{@"name":@"Artist", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Artist"]};
    NSDictionary* objectParam12 = @{@"name":@"FNumber", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"FNumber"]};
    NSDictionary* objectParam13 = @{@"name":@"ISO", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"ISO"]};
    NSDictionary* objectParam14 = @{@"name":@"MaxApertureValue", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"MaxApertureValue"]};
    NSDictionary* objectParam15 = @{@"name":@"ExposureCompensation", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"ExposureCompensation"]};
    NSDictionary* objectParam16 = @{@"name":@"Flash", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Flash"]};
    NSDictionary* objectParam17 = @{@"name":@"LensInfo", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"LensInfo"]};
    NSDictionary* objectParam18 = @{@"name":@"LensInfo", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"LensInfo"]};
    NSDictionary* objectParam19 = @{@"name":@"Lens", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Lens"]};
    NSDictionary* objectParam20 = @{@"name":@"fullScreenThumbUrl", @"type":[NSNumber numberWithInt:TypeText], @"value":@""};
    NSDictionary* objectParam21 = @{@"name":@"fullViewUrl", @"type":[NSNumber numberWithInt:TypeText], @"value":@""};

    
    [sqlManager insertObject:objectParam1,objectParam2,objectParam3,objectParam4,objectParam5,objectParam6,objectParam7,objectParam8,objectParam9,objectParam10,objectParam11,objectParam12,objectParam13,objectParam14,objectParam15,objectParam16,objectParam17,objectParam18,objectParam19,objectParam20,objectParam21,nil];

    /*
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
    */
}

- (void)insertFlickrDataToDB:(NSDictionary*)photoData exifData:(NSDictionary *)metaData
{
    SQLiteManager* sqlManager = [SQLiteManager sharedSQLiteManager:(NSString*)cDBFileName];
    NSString* select = @"select * from";
    NSURL* url = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeLargeSquare150 photoData:photoData];
    NSString* where = [NSString stringWithFormat:@"where url = '%@' order by sectionDate asc", [url absoluteString]];
    NSMutableArray* arrayOfItem = [self performSelect:select where:where];
    if( arrayOfItem.count != 0 ){
        return;
    }
    NSDictionary* objectParam1 = @{@"name":@"DateTimeOriginal", @"type":[NSNumber numberWithInt:TypeReal], @"value":[NSNumber numberWithDouble:[self convertUnixDateTime:[metaData valueForKey:@"DateTimeOriginal"]]] };
    NSDictionary* objectParam2 = @{@"name":@"groupName", @"type":[NSNumber numberWithInt:TypeText], @"value":@"Flicker"};
    NSDictionary* objectParam3 = @{@"name":@"sectionDate", @"type":[NSNumber numberWithInt:TypeText], @"value":[self makeShortDateString:[metaData valueForKey:@"DateTimeOriginal"]]};
    NSDictionary* objectParam4 = @{@"name":@"url", @"type":[NSNumber numberWithInt:TypeText], @"value":[url absoluteString]};
    NSDictionary* objectParam5 = @{@"name":@"groupUrl", @"type":[NSNumber numberWithInt:TypeText], @"value":@"flickr://"};
    NSDictionary* objectParam6 = @{@"name":@"Model", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Model"]};
    NSDictionary* objectParam7 = @{@"name":@"Maker", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Maker"]};
    
    NSDictionary* objectParam8 = @{@"name":@"ExposureTime", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"ExposureTime"]};
    NSDictionary* objectParam9 = @{@"name":@"FocalLength", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"FocalLength"]};
    NSDictionary* objectParam10 = @{@"name":@"Orientation", @"type":[NSNumber numberWithInt:TypeInteger], @"value":[self cnvertNumber: [metaData valueForKey:@"Orientation"]]};
    NSDictionary* objectParam11 = @{@"name":@"Artist", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Artist"]};
    NSDictionary* objectParam12 = @{@"name":@"FNumber", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"FNumber"]};
    NSDictionary* objectParam13 = @{@"name":@"ISO", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"ISO"]};
    NSDictionary* objectParam14 = @{@"name":@"MaxApertureValue", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"MaxApertureValue"]};
    NSDictionary* objectParam15 = @{@"name":@"ExposureCompensation", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"ExposureCompensation"]};
    NSDictionary* objectParam16 = @{@"name":@"Flash", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Flash"]};
    NSDictionary* objectParam17 = @{@"name":@"LensInfo", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"LensInfo"]};
    NSDictionary* objectParam18 = @{@"name":@"LensInfo", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"LensInfo"]};
    NSDictionary* objectParam19 = @{@"name":@"Lens", @"type":[NSNumber numberWithInt:TypeText], @"value":[metaData valueForKey:@"Lens"]};
    NSURL* fullScreenUrl = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeLarge1024 photoData:photoData];
    NSDictionary* objectParam20 = @{@"name":@"fullScreenThumbUrl", @"type":[NSNumber numberWithInt:TypeText], @"value":[fullScreenUrl absoluteString]};
    NSURL* fullViewnUrl = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeOriginal photoData:photoData];
    NSDictionary* objectParam21 = @{@"name":@"fullViewUrl", @"type":[NSNumber numberWithInt:TypeText], @"value":[fullViewnUrl absoluteString]};
    
    
    [sqlManager insertObject:objectParam1,objectParam2,objectParam3,objectParam4,objectParam5,objectParam6,objectParam7,objectParam8,objectParam9,objectParam10,objectParam11,objectParam12,objectParam13,objectParam14,objectParam15,objectParam16,objectParam17,objectParam18,objectParam19,objectParam20,objectParam21,nil];
    
}

- (void)initializeLibrary
{
    self.m_assetGroups = [[NSMutableArray alloc] init];
    self.m_sectionDatas = [[NSMutableArray alloc] init];
    self.m_flickrPhotos = [[NSMutableArray alloc] init];
    
    m_assetMngr = [AssetManager sharedAssetManager];
     [m_assetMngr setAssetManagerModeIsHoldItemData:NO];
    m_assetMngr.delegate = self;
    //[m_assetMngr enumeAssetItems];

    m_flickrMngr = [FlickrMngr sharedFlkckrMngr];
    [m_flickrMngr initialize];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(flickrDataLoad:) name:@"StartFlickrDataLoad" object:nil];
    
    SQLiteManager* sqlManager = [SQLiteManager sharedSQLiteManager:(NSString*)cDBFileName];
    [sqlManager openDB];
    [self createMainTable];
    [sqlManager createIndex:@"urlIndex" column:@"url"];
    [sqlManager createIndex:@"dateIndex" column:@"sectionDate"];
    
    _fetchResultArray = [self performSelect:@"select * from" where:@"where Maker = 'Canon' order by sectionDate asc"];
    NSArray* array = [_fetchResultArray valueForKeyPath:@"groupName"];
    _groupNames = [[NSMutableArray alloc] init ];
    for( NSString* name in array ){
        if( ![_groupNames containsObject:name] ){
            [_groupNames addObject:name];
        }
    }
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_groupNames forKey:@"groupNames"];
    if ( ![defaults synchronize] ) {
        NSLog( @"failed ..." );
    }
    
    _groupArray = [[NSMutableArray alloc] init];
    for( NSString* groupName in _groupNames){
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"groupName = %@",groupName];
        NSArray* results = [_fetchResultArray filteredArrayUsingPredicate:predicate];
        [_groupArray addObject:results];
    }

}

- (void)flickrDataLoad:(NSNotification *)notification
{
    
    [m_flickrMngr getPhotoList:^(NSArray *photos) {
        @autoreleasepool{
            dispatch_async(dispatch_get_main_queue(), ^{
                __block NSInteger count = 0;
                for( NSDictionary* photoData in photos )
                {
                    
                    //FlickrPhotoData* data = [[FlickrPhotoData alloc] init];
                    //data.m_photoData = [photoData copy];
                    //NSURL* url = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeLargeSquare150 photoData:photoData];
                    //data.m_thumbnailUrl = url;
                    
                    [m_flickrMngr getExifData:photoData completion:^(NSDictionary *exifData) {
                        ///dispatch_async(dispatch_get_main_queue(), ^{
                            [self insertFlickrDataToDB:photoData exifData:exifData];
                            //data.m_exifData = [exifData copy];
                            //[self.m_flickrPhotos addObject:data];
                            count++;
                            if( count == photos.count )
                            {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSLog(@"===== set exif data %d======",count);
                                    [self.delegate updateView];
                                });
                            }
                       // });
                        
                    }];
                    
                }
            });
        }
    }];    
}

- (UIImage*)GetFlickrThumbnailAtGroup:(NSInteger)index
{
    
    NSInteger count = 0;
    for( NSString* name in _groupNames ){
        if( [name compare:@"Flickr"] == NSOrderedSame ){
            break;
        }
        count++;
    }
    NSDictionary* dict = _groupArray[index];
    NSURL* url = [NSURL URLWithString:[dict valueForKey:@"url"]];
    
    //FlickrPhotoData* filkrPhoto = self.m_flickrPhotos[index];
    __block UIImage* image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [m_flickrMngr getPhotoData:url completion:^(UIImage *photoData) {
            image = photoData;
        }];
    });
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;
}

- (UIImage*)GetFlickrThumbnail:(NSURL*)url
{
    __block UIImage* image = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [m_flickrMngr getPhotoData:url completion:^(UIImage *photoData) {
            image = photoData;
        }];
    });
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;
}

- (UIImage*)GetFlickrAspectThumbnail:(NSURL*)url
{
//    FlickrPhotoData* targetPhoto;
//    for( FlickrPhotoData* filkrPhoto in self.m_flickrPhotos ){
//        if( filkrPhoto.m_thumbnailUrl == url ){
//            targetPhoto = filkrPhoto;
//            break;
//        }
//    }
    __block UIImage* image = nil;
    
//    NSURL* targetUrl = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeSmall240 photoData:targetPhoto.m_photoData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [m_flickrMngr getPhotoData:url completion:^(UIImage *photoData) {
            image = photoData;
        }];
    });
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;
}

- (UIImage*)GetFlickrFullSizeImage:(NSURL*)url
{
//    FlickrPhotoData* targetPhoto;
//    for( FlickrPhotoData* filkrPhoto in self.m_flickrPhotos ){
//        if( filkrPhoto.m_thumbnailUrl == url ){
//            targetPhoto = filkrPhoto;
//            break;
//        }
//    }
    __block UIImage* image = nil;
    
//    NSURL* targetUrl = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeOriginal photoData:targetPhoto.m_photoData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [m_flickrMngr getPhotoData:url completion:^(UIImage *photoData) {
            image = photoData;
        }];
    });
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;

}

- (UIImage*)GetFlickrFullScreenSizeImage:(NSURL*)url
{
//    FlickrPhotoData* targetPhoto;
//    for( FlickrPhotoData* filkrPhoto in self.m_flickrPhotos ){
//        if( filkrPhoto.m_thumbnailUrl == url ){
//           targetPhoto = filkrPhoto;
//           break;
//        }
//    }
    __block UIImage* image = nil;
    
//    NSURL* targetUrl = [m_flickrMngr makePhotoURLBySize:FMPhotoSizeLarge1024 photoData:targetPhoto.m_photoData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [m_flickrMngr getPhotoData:url completion:^(UIImage *photoData) {
            image = photoData;
        }];
    });
    while (image == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    return image;
}

/*
- (NSDictionary*)GetFlickrMetaData:(NSURL*)url
{
    FlickrPhotoData* targetPhoto;
    for( FlickrPhotoData* filkrPhoto in self.m_flickrPhotos ){
        if( filkrPhoto.m_thumbnailUrl == url ){
            targetPhoto = filkrPhoto;
            break;
        }
    }
    return targetPhoto.m_exifData;
}
*/

/*
- (void)createSectionForFlickr
{
    for( FlickrPhotoData* photo in self.m_flickrPhotos )
    {
        NSDictionary* exifDict = photo.m_exifData;
        NSString* dateTimeString = [exifDict valueForKey:@"DateTimeOriginal"];
        NSArray* separateString = [dateTimeString componentsSeparatedByString:@" "];
        NSString* dateString = separateString[0];
        NSString* sectionDateString = [dateString stringByReplacingOccurrencesOfString:@":" withString:@"/"];
        if( sectionDateString == nil )
            sectionDateString = @"Unknown";
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
*/

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
    _currentGroupIndex = groupIndex;
    [self rebuildSectionItems:@"sectionDate"];
    /*
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
    */
}

- (NSInteger)getGroupCount
{
    return _groupNames.count;
    /*
    NSInteger num = self.m_assetGroups.count;
    if(m_isFlickr)
    {
        if( self.m_flickrPhotos.count != 0 )
        {
            num++;
        }
    }
    return num;
    */
}

- (NSInteger)getSectionCount
{
    return _sections.count;
    /*
    NSInteger num = self.m_sectionDatas.count;
    return self.m_sectionDatas.count;
    */
}

- (NSArray*)getGroupNames
{
    return _groupNames;
    /*
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
    */
}


- (NSArray*)getSectionNames
{
    return _sections;
    /*
    NSMutableArray* array = [[NSMutableArray alloc] init];
    for( SectionData* section in self.m_sectionDatas )
    {
        [array addObject:section.sectionTitle];
    }
    return array;
    */
}

/*
- (NSString*)getSectonNameAtGroup:(NSString*)groupName index:(NSInteger)index
{
    return [m_assetMngr getGroupNames][index];
}
*/
- (NSString*)getGroupNameAtIndex:(NSInteger)index
{
    return _groupNames[index];
    /*
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
     */
}

- (NSInteger)getNumOfImagesInGroup:(NSString*)groupName
{
    NSInteger index = 0;
    NSInteger count = 0;
    for( NSString* name in _groupNames ){
        if( [name compare:groupName] == NSOrderedSame ){
            NSArray* array = _groupArray[index];
            count = array.count;
        }
        index++;
    }
    return  count;
    
    /*
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
    */
}

- (NSInteger)getNumOfImagesInSectionBySectonIndex:(NSInteger)sectionIndex
{
    NSArray* array = _sectionItems[sectionIndex];
    return array.count;
    /*
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    NSInteger num = sectionData.items.count;
    return num;
    */
}
- (NSInteger)getNumOfImagesInSection:(NSString*)sectionName
{
    NSInteger index = 0;
    NSInteger count = 0;
    for( NSString* name in _sections ){
        if( [name compare:sectionName] == NSOrderedSame ){
            NSArray* array = _sectionItems[index];
            count = array.count;
        }
        index++;
    }
    return  count;
    
    /*
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
    */
}

- (NSArray*)getItemsInSectionByIndex:(NSInteger)sectionIndex
{
    NSArray* array = _sectionItems[sectionIndex];
    return array;
    /*
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    return sectionData.items;
    */
}

- (UIImage*)getThumbnailAtGroupByIndex:(NSInteger)groupIndex index:(NSInteger)index
{
    UIImage* image;
    NSArray* array = _groupArray[groupIndex];
    NSDictionary* info = array[index];
    NSString* groupUrlString = [info valueForKey:@"groupUrl"];
    if( [groupUrlString compare:@"flickr://"] == NSOrderedSame ){
        image = [self GetFlickrThumbnail:[NSURL URLWithString:[info valueForKey:@"url"]]];
    }else{
        image = [m_assetMngr getThumbnail:[NSURL URLWithString:[info valueForKey:@"url"]]];
    }
    return image;
    /*
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
    */
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
    UIImage* image;
    NSArray* array = _sectionItems[sectionIndex];
    NSDictionary* info = array[index];
    NSString* groupUrlString = [info valueForKey:@"groupUrl"];
    if( [groupUrlString compare:@"flickr://"] == NSOrderedSame ){
        image = [self GetFlickrThumbnail:[NSURL URLWithString:[info valueForKey:@"url"]]];
    }else{
        image = [m_assetMngr getThumbnail:[NSURL URLWithString:[info valueForKey:@"url"]]];
    }
    return image;
/*
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getThumbnail:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrThumbnail:sectionData.items[index]];
    }
    return nil;
*/
}

// 2014/04/30 ここまで

- (UIImage*)getAspectThumbnailAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index
{
    UIImage* image;
    NSArray* array = _sectionItems[sectionIndex];
    NSDictionary* info = array[index];
    NSString* groupUrlString = [info valueForKey:@"groupUrl"];
    if( [groupUrlString compare:@"flickr://"] == NSOrderedSame ){
        image = [self GetFlickrAspectThumbnail:[NSURL URLWithString:[info valueForKey:@"url"]]];
    }else{
        image = [m_assetMngr getThumbnailAspect:[NSURL URLWithString:[info valueForKey:@"url"]]];
    }
    return image;
/*
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getThumbnailAspect:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrAspectThumbnail:sectionData.items[index]];
    }
    return nil;
*/
}

- (UIImage*)getFullViewImageAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index
{
    UIImage* image;
    NSArray* array = _sectionItems[sectionIndex];
    NSDictionary* info = array[index];
    NSString* groupUrlString = [info valueForKey:@"groupUrl"];
    if( [groupUrlString compare:@"flickr://"] == NSOrderedSame ){
        image = [self GetFlickrFullSizeImage:[NSURL URLWithString:[info valueForKey:@"fullViewUrl"]]];
    }else{
        image = [m_assetMngr getFullImage:[NSURL URLWithString:[info valueForKey:@"url"]]];
    }
    return image;
/*
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getFullImage:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrFullSizeImage:sectionData.items[index]];
    }
    return nil;
*/
}

- (UIImage*)getFullSreenViewImageAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index
{
    UIImage* image;
    NSArray* array = _sectionItems[sectionIndex];
    NSDictionary* info = array[index];
    NSString* groupUrlString = [info valueForKey:@"groupUrl"];
    if( [groupUrlString compare:@"flickr://"] == NSOrderedSame ){
        image = [self GetFlickrFullScreenSizeImage:[NSURL URLWithString:[info valueForKey:@"fullScreenThumbUrl"]]];
    }else{
        image = [m_assetMngr getFullScreenImage:[NSURL URLWithString:[info valueForKey:@"url"]]];
    }
    return image;
/*
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getFullScreenImage:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrFullScreenSizeImage:sectionData.items[index]];
    }
    return nil;
*/
}

- (NSDictionary*)getMetaDataBySectionIndex:(NSInteger)sectionIndex index:(NSInteger)index
{
    NSArray* array = _sectionItems[sectionIndex];
    NSDictionary* info = array[index];
    return info;
/*
    SectionData* sectionData = self.m_sectionDatas[sectionIndex];
    if( sectionData.kind == SectionKindIsLocal){
        return [m_assetMngr getMetaDataByURL:sectionData.items[index]];
    }else if( sectionData.kind == SectionKindIsFlickr ){
        return [self GetFlickrMetaData:sectionData.items[index]];
    }
    return nil;
*/
}

- (void)cleanupSectionsData
{
    [_sectionItems removeAllObjects];
    [_sections removeAllObjects];
/*
    for( SectionData* section in self.m_sectionDatas )
    {
        [section.items removeAllObjects];
        section.items = nil;
    }
    [self.m_sectionDatas removeAllObjects];
    //m_sectionDatas = nil;
*/
}

- (void)createMainTable
{
    SQLiteManager* sqlManager = [SQLiteManager sharedSQLiteManager:(NSString*)cDBFileName];
    NSDictionary* column1 = @{@"name":@"DateTimeOriginal", @"type":@"double"};
    NSDictionary* column2 = @{@"name":@"groupName", @"type":@"text"};
    NSDictionary* column3 = @{@"name":@"sectionDate", @"type":@"text"};
    NSDictionary* column4 = @{@"name":@"url", @"type":@"text"};
    NSDictionary* column5 = @{@"name":@"groupUrl", @"type":@"text"};
    NSDictionary* column6 = @{@"name":@"Model", @"type":@"text"};
    NSDictionary* column7 = @{@"name":@"Maker", @"type":@"text"};
    NSDictionary* column8 = @{@"name":@"ExposureTime", @"type":@"text"};
    NSDictionary* column9 = @{@"name":@"FocalLength", @"type":@"text"};
    NSDictionary* column10 = @{@"name":@"Orientation", @"type":@"integer"};
    NSDictionary* column11 = @{@"name":@"Artist", @"type":@"text"};
    NSDictionary* column12 = @{@"name":@"FNumber", @"type":@"text"};
    NSDictionary* column13 = @{@"name":@"ISO", @"type":@"text"};
    NSDictionary* column14 = @{@"name":@"MaxApertureValue", @"type":@"text"};
    NSDictionary* column15 = @{@"name":@"ExposureCompensation", @"type":@"text"};
    NSDictionary* column16 = @{@"name":@"Flash", @"type":@"text"};
    NSDictionary* column17 = @{@"name":@"LensInfo", @"type":@"text"};
    NSDictionary* column18 = @{@"name":@"LensModel", @"type":@"text"};
    NSDictionary* column19 = @{@"name":@"Lens", @"type":@"text"};
    NSDictionary* column20 = @{@"name":@"fullScreenThumbUrl", @"type":@"text"};
    NSDictionary* column21 = @{@"name":@"fullViewUrl", @"type":@"text"};
    
    
    NSArray* columns = @[column1,column2,column3,column4,column5,column6,column7,column8,column9,column10,column11,column12,column13,column14,column15,column16,column17,column18,column19,column20, column21 ];
    [sqlManager createTable:@"imageInfoTable" columns:columns];
}

- (NSString*)makeShortDateString:(NSString*)dateTime
{
    NSArray* strArray = [dateTime componentsSeparatedByString:@" "];
    NSString* str = [strArray[0] stringByReplacingOccurrencesOfString:@":" withString:@"/"];
    NSString* str2 = [str stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
    return str2;
    
    //NSDate* date = [self dateTime:dateTime];
    //return [self dateTimeString:date];
}

- (double)convertUnixDateTime:(NSString*)dateTimeString
{
    NSDate* date = [self dateTime:dateTimeString];
    double seconds = [date timeIntervalSince1970];
    return seconds;
}

- (NSDate*)convertUnixDataToNSDate:(double)time
{
    NSDate* nsDate = [NSDate dateWithTimeIntervalSince1970:time];
    return nsDate;
}
- (NSString*)dateTimeString:(NSDate*)dateTime
{
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"yyyy/mm/dd"];
    return [inputDateFormatter stringFromDate:dateTime];
    
}

- (NSDate*)dateTime:(NSString*)dateTime
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"YYYY:MM:DD HH:MM:SS"];
    NSDate *formatterDate = [inputFormatter dateFromString:dateTime];
    if(formatterDate == nil){
        [inputFormatter setDateFormat:@"yyyy-MM-dd HH:MM:SS"];
        formatterDate = [inputFormatter dateFromString:dateTime];
        if( formatterDate == nil ){
            formatterDate = 0;
        }
    }
    return formatterDate;
}

- (NSNumber*)cnvertNumber:(NSString*)number
{
    int num = [number intValue];
    return [NSNumber numberWithInt:num];
}

- (void)deleteImage
{
    SQLiteManager* sqlManager = [SQLiteManager sharedSQLiteManager:(NSString*)cDBFileName];
    if( [sqlManager deleteObjectWhere:nil] == YES ){
        [_fetchResultArray removeAllObjects];
    }
    //[self.tableView reloadData];
}

- (void)refleshImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        AssetManager* assetManager = [AssetManager sharedAssetManager];
        [assetManager enumeAssetItems];
    });
}

- (NSMutableArray*)performSelect:(NSString*)selectString where:(NSString*)whereString
{
    NSDictionary* resultCol1 = @{@"name":@"DateTimeOriginal", @"index":[NSNumber numberWithInt:0], @"type":[NSNumber numberWithInt:TypeReal]};
    NSDictionary* resultCol2 = @{@"name":@"groupName", @"index":[NSNumber numberWithInt:1], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol3 = @{@"name":@"sectionDate", @"index":[NSNumber numberWithInt:2], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol4 = @{@"name":@"url", @"index":[NSNumber numberWithInt:3], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol5 = @{@"name":@"groupUrl", @"index":[NSNumber numberWithInt:4], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol6 = @{@"name":@"Model", @"index":[NSNumber numberWithInt:5], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol7 = @{@"name":@"Maker", @"index":[NSNumber numberWithInt:6], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol8 = @{@"name":@"ExposureTime", @"index":[NSNumber numberWithInt:7], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol9 = @{@"name":@"FocalLength", @"index":[NSNumber numberWithInt:8], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol10 = @{@"name":@"Orientation", @"index":[NSNumber numberWithInt:9], @"type":[NSNumber numberWithInt:TypeInteger]};
    NSDictionary* resultCol11 = @{@"name":@"Artist", @"index":[NSNumber numberWithInt:10], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol12 = @{@"name":@"FNumber", @"index":[NSNumber numberWithInt:11], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol13 = @{@"name":@"ISO", @"index":[NSNumber numberWithInt:12], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol14 = @{@"name":@"MaxApertureValue", @"index":[NSNumber numberWithInt:13], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol15 = @{@"name":@"ExposureCompensation", @"index":[NSNumber numberWithInt:14], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol16 = @{@"name":@"Flash", @"index":[NSNumber numberWithInt:15], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol17 = @{@"name":@"LensInfo", @"index":[NSNumber numberWithInt:16], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol18 = @{@"name":@"LensModel", @"index":[NSNumber numberWithInt:17], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol19 = @{@"name":@"Lens", @"index":[NSNumber numberWithInt:18], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol20 = @{@"name":@"fullScreenThumbUrl", @"index":[NSNumber numberWithInt:18], @"type":[NSNumber numberWithInt:TypeText]};
    NSDictionary* resultCol21 = @{@"name":@"fullViewUrl", @"index":[NSNumber numberWithInt:18], @"type":[NSNumber numberWithInt:TypeText]};
    
    
    NSArray* resultFormat = @[resultCol1,resultCol2,resultCol3,resultCol4,resultCol5,resultCol6,resultCol7,resultCol8,resultCol9,resultCol10,resultCol11,resultCol12,resultCol13,resultCol14,resultCol15,resultCol16,resultCol17,resultCol18,resultCol19,resultCol20,resultCol21];
    
    SQLiteManager* sqlManager = [SQLiteManager sharedSQLiteManager:(NSString*)cDBFileName];
    return [NSMutableArray arrayWithArray:[sqlManager fetchResultOnSelect:selectString whereAndOrder:whereString format:resultFormat]];
    
}

- (void)rebuildSectionItems:(NSString*)sectionName
{
    _sectionKindString = sectionName;
    NSArray* array = [_groupArray[_currentGroupIndex] valueForKeyPath:_sectionKindString];
    if( _sections == nil ){
        _sections = [[NSMutableArray alloc] init ];
    }
    [_sections removeAllObjects];
    for( NSString* name in array ){
        if( ![_sections containsObject:name] ){
            [_sections addObject:name];
        }
    }
    if( _sectionItems == nil){
        _sectionItems = [[NSMutableArray alloc] init];
    }
    [_sectionItems removeAllObjects];
    for( NSString* name in _sections){
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K = %@",sectionName, name];
        NSArray* items = [_groupArray filteredArrayUsingPredicate:predicate];
        [_sectionItems addObject:items];
    }
}


@end
