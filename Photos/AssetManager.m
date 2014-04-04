//
//  AssetManager.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/10.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "AssetManager.h"
#import "AssetGroupData.h"

@interface AssetManager ()
@property (nonatomic, retain) ALAssetsLibrary* m_assetLibrary;
@property (nonatomic, retain) NSMutableArray* m_assetsGroups;   /* AssetGroupData array */
@property BOOL m_isHoldItemData;
@end


@implementation AssetManager

static AssetManager* g_assetManager = nil;

+ (AssetManager*)sharedAssetManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool{
            g_assetManager = [[AssetManager alloc] init];
            g_assetManager.m_assetLibrary = [[ALAssetsLibrary alloc] init];
            g_assetManager.m_assetsGroups = [[NSMutableArray alloc] init];
        }
    });
    return g_assetManager;
}

- (void)setAssetManagerModeIsHoldItemData:(BOOL)isHold
{
    self.m_isHoldItemData = isHold;
}

- (void)enumeAssetItems
{
    void (^groupBlock)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop){
        @autoreleasepool {
            if( group != nil )
            {
                AssetGroupData* data = [[AssetGroupData alloc] init];
                data.m_assetGroup = group;
                if( self.m_isHoldItemData )
                {
                    data.m_assets = [[NSMutableArray alloc] init];
                }else{
                    data.m_assets = nil;
                }
                [self enumAssets:data];
                [self.m_assetsGroups addObject:data];
                NSLog(@"Group:%@ images:%lu",[group valueForProperty:ALAssetsGroupPropertyName], (unsigned long)data.m_assets.count );
                NSURL* groupUrl = [group valueForProperty:ALAssetsGroupPropertyURL];
                [self.delegate updateGroupDataGroupURL:groupUrl];
            }
        }
    };
    [self.m_assetLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:groupBlock failureBlock:^(NSError *error) {
        NSLog(@"AssetLib error %@",error);
    }];
}


- (UIImage*)getThumbnail:(NSURL*)url
{
    @autoreleasepool {
        ALAsset* asset = [self getAssetByURL:url];
        UIImage* image = [UIImage imageWithCGImage:[asset thumbnail]];
        return image;
    }
}

- (UIImage*)getThumbnailAspect:(NSURL *)url
{
    @autoreleasepool {
        ALAsset* asset = [self getAssetByURL:url];
        
        UIImage* image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        if( image == nil )
        {
            image = [UIImage imageWithCGImage:[asset thumbnail]];
        }
        return image;
    }
}

- (UIImage*)getFullImage:(NSURL*)url
{
    @autoreleasepool {
        ALAsset* asset = [self getAssetByURL:url];
        ALAssetRepresentation* assetRepresentaion = [asset defaultRepresentation];
        UIImage* image = [UIImage imageWithCGImage:[assetRepresentaion fullResolutionImage]];
        return image;
    }
}

- (UIImage*)getFullScreenImage:(NSURL*)url
{
    @autoreleasepool {
        ALAsset* asset = [self getAssetByURL:url];
        ALAssetRepresentation* assetRepresentaion = [asset defaultRepresentation];
        UIImage* image = [UIImage imageWithCGImage:[assetRepresentaion fullScreenImage]];
        return image;
    }
}

- (NSString*)getGroupNameByURL:(NSURL*)url
{
    @autoreleasepool {
        NSString* name;
        ALAssetsGroup* assetGroup = [self getAssetGroupByURL:url];
        name = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
        return name;
    }
}
- (NSArray*)getGroupNames
{
    NSMutableArray* array = [[NSMutableArray alloc ] init];
    for( AssetGroupData* data in self.m_assetsGroups )
    {
        NSString* name = [data.m_assetGroup valueForProperty:ALAssetsGroupPropertyName];
        [array addObject:name];
    }
    NSArray* retArray = [[NSArray alloc] initWithArray:array];
    return retArray;
}

/*
- (NSString*)getGroupNameByURL:(NSURL*)url
{
    NSString* name;
    ALAssetsGroup* assetGroup = [self getAssetGroupByURL:url];
    name = [assetGroup valueForProperty:ALAssetsGroupPropertyName];
    return name;
}
*/

- (NSInteger)getCountOfImagesInGroup:(NSString*)name
{
    @autoreleasepool {
        NSInteger num;
        for( AssetGroupData* data in self.m_assetsGroups )
        {
            NSString* currentStr = [data.m_assetGroup valueForProperty:ALAssetsGroupPropertyName];
            if( [currentStr isEqual:name] )
            {
                num = [data.m_assetGroup numberOfAssets];
            }
        }
        return num;
    }
}
- (NSInteger)getCountOfImagesInGroupByURL:(NSURL*)url
{
    @autoreleasepool {
        NSInteger num;
        for( AssetGroupData* data in self.m_assetsGroups )
        {
            NSURL* currentUrl = [data.m_assetGroup valueForProperty:ALAssetsGroupPropertyURL];
            if( [currentUrl isEqual:url] )
            {
                num = [data.m_assetGroup numberOfAssets];
            }
        }
        return num;
    }
}
- (NSDate*)getCaptureDateByURL:(NSURL*)url
{
    @autoreleasepool {
        ALAsset* asset = [self getAssetByURL:url];
        NSDate* date = [asset valueForProperty:ALAssetPropertyDate];
        return date;
    }
}

- (NSDictionary*)getMetaDataByURL:(NSURL*)url
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    @autoreleasepool {
        ALAsset* asset = [self getAssetByURL:url];
        ALAssetRepresentation* assetRepresentaion = [asset defaultRepresentation];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"TIFF.Make" ] forKey:@"Make"];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"TIFF.Model" ] forKey:@"Model"];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"Orientation" ] forKey:@"Orientation"];
        [dict setObject:nil forKey:@"Artist"];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"Exif.ExposureTime" ] forKey:@"ExposureTime"];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"Exif.FNumber" ] forKey:@"FNumber"];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"Exif.ISOSpeedRatings" ] forKey:@"ISO"];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"Exif.DateTimeOriginal" ] forKey:@"Dariginal"];
        [dict setObject:nil forKey:@"ExposureCompensation"];
        [dict setObject:nil forKey:@"MaxApertureValue"];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"Exif.Flash" ] forKey:@"Flash"];
        [dict setObject:[assetRepresentaion.metadata valueForKeyPath:@"Exif.FocalLength" ] forKey:@"FocalLength"];
        [dict setObject:nil forKey:@"LensInfo"];
        [dict setObject:nil forKey:@"LensModel"];
        [dict setObject:nil forKey:@"Lens"];
       
    }
    return dict;
}

// ------- internal functions -------------------------------------------------------------------------

- (void)enumAssets:(AssetGroupData*)groupData
{
    void (^photosBlock)(ALAsset*, NSUInteger, BOOL*) = ^(ALAsset* asset, NSUInteger index, BOOL* stop){
        if( ![groupData.m_assets  containsObject:asset] )
        {
            if( [[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto] )
            {
                if( self.m_isHoldItemData )
                {
                    [groupData.m_assets  addObject:asset];
                }
                NSURL* url = [asset valueForProperty:ALAssetPropertyAssetURL];
                NSURL* groupUrl = [groupData.m_assetGroup valueForProperty:ALAssetsGroupPropertyURL];
                [self.delegate updateItemDataItemURL:url groupURL:groupUrl];
            }
        }
    };
    [groupData.m_assetGroup enumerateAssetsUsingBlock:photosBlock];
}

- (ALAssetsGroup*)getAssetGroupByURL:(NSURL*)url
{
    __block ALAssetsGroup* retAssetGroup = nil;
    void (^getAssetGroupBlock)(ALAssetsGroup*) = ^(ALAssetsGroup* assetGroup){
        retAssetGroup = assetGroup;
    };
    
    void (^failBlock)(NSError*) = ^(NSError* error){
        NSLog(@"exception in accessing assets by url. %@", error);
    };
    [self.m_assetLibrary groupForURL:url resultBlock:getAssetGroupBlock failureBlock:failBlock];
    while (retAssetGroup == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    
    return retAssetGroup;
}

- (ALAsset*)getAssetByURL:(NSURL*)url
{
    __block ALAsset* retAsset = nil;
    void (^getAssetBlock)(ALAsset*) = ^(ALAsset* asset){
        @autoreleasepool{
            retAsset = asset;
        }
    };
    
    void (^failBlock)(NSError*) = ^(NSError* error){
        NSLog(@"exception in accessing assets by url. %@", error);
    };
    [self.m_assetLibrary assetForURL:url resultBlock:getAssetBlock failureBlock:failBlock];
    while (retAsset == nil) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.001]];
    }
    
    return retAsset;
}

- (void)getAssetByURL:(NSURL*)url selector:(SEL)foundAsset withObject:(id)obj
{
    void (^getAssetBlock)(ALAsset*) = ^(ALAsset* asset){
        @autoreleasepool{
            [self performSelector: foundAsset withObject:(id)asset afterDelay:0.0f];
        }
    };
    
    void (^failBlock)(NSError*) = ^(NSError* error){
        NSLog(@"exception in accessing assets by url. %@", error);
    };
    
    [self.m_assetLibrary assetForURL:url resultBlock:getAssetBlock failureBlock:failBlock];
}

- (void)foundAsset:(ALAsset*)asset
{
    
}


@end
