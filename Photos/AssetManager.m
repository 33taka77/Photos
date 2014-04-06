//
//  AssetManager.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/10.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "AssetManager.h"
#import "AssetGroupData.h"
#import <ImageIO/ImageIO.h>

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

- (NSString*)makeExposureString:(NSNumber*)exposure
{
    if( exposure == nil )
        return @"";
    int i =0;
    double val = [exposure doubleValue];
    int intVal;
    intVal = (int)val;
    while (fmod(val,intVal) != 0.0) {
        val = val*10;
        i++;
        if( i > 7)
            break;
        intVal = (int)val;
    }
    int bunsi;
    int bunbo;
    bunsi = val;
    bunbo = pow(10,i);
    
    int a0;
    int b0;
    int a=bunsi;
    int b=bunbo;
    a0=a;
    b0=b;
    int c;
    while(1)
    {
        c=b%a;if(c==0)break;
        b=a;
        a=c;
    }
    bunsi = a0/a;
    bunbo = b0/a;
    NSString* str;
    if( bunbo == 1 )
    {
        str = [NSString stringWithFormat:@"%d",bunsi];
    }else{
        str = [NSString stringWithFormat:@"%d/%d",bunsi, bunbo];
    }
    return str;
    
}

- (NSString*)makeFNumberString:(NSNumber*)fnumber
{
    if( fnumber == nil )
        return @"";
    NSString* str;
    double val = [fnumber doubleValue];
    str = [NSString stringWithFormat:@"%f",val];
    return str;
}

- (NSString*)makeISOString:(NSArray*)iso
{
    if( iso == nil )
        return @"";
    NSNumber* isoNumber = iso[0];
    NSString* str = [isoNumber stringValue];
    return str;
}

- (NSString*)makeFlashString:(NSNumber*)flash
{
    if( flash == nil )
        return @"";
    NSString* str;
    double val = [flash doubleValue];
    int intVal = (int)val;
    if( (intVal&0x00000001) != 0 )
    {
        str = @"Flash ON";
    }else{
        str = @"Flash OFF";
    }
    return str;
}

- (NSString*)makeFocalLengthString:(NSNumber*)forcalLength
{
    if( forcalLength == nil )
        return @"";
    NSString* str;
    str = [forcalLength stringValue];
    return str;
}

- (NSDictionary*)getmetadata:(ALAssetRepresentation*)assetRepresentation
{
    @autoreleasepool {
        NSUInteger size = (NSInteger)[assetRepresentation size];
        uint8_t *buff = (uint8_t *)malloc(sizeof(uint8_t)*size);
        NSData *photo;
        if(buff != nil){
            NSError *error = nil;
            NSUInteger bytesRead = [assetRepresentation getBytes:buff fromOffset:0 length:size error:&error];
            if (bytesRead && !error) {
                photo = [NSData dataWithBytesNoCopy:buff length:bytesRead freeWhenDone:YES];
            }
            if (error) {
                NSLog(@"error:%@", error);
                free(buff);
                return nil;
            }
        }
        CGImageSourceRef cgImage = CGImageSourceCreateWithData((CFDataRef)CFBridgingRetain(photo), nil);
        NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(cgImage, 0, nil));
        if (metadata) {
            NSLog(@"%@", [metadata description]);
        } else {
            NSLog(@"no metadata");
        }
        free(buff);
        CFRelease(cgImage);
        return metadata;
    }
}

- (NSDictionary*)getMetaDataByURL:(NSURL*)url
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    @autoreleasepool {
        ALAsset* asset = [self getAssetByURL:url];
        ALAssetRepresentation* assetRepresentaion = [asset defaultRepresentation];
        //NSDictionary* metaData = assetRepresentaion.metadata;
        NSDictionary* metaData = [self getmetadata:assetRepresentaion];
        
        NSDictionary* exif = [metaData valueForKey:@"{Exif}"];
        NSString* strMaker = [assetRepresentaion.metadata valueForKeyPath:@"{TIFF}.Make" ];
        if( strMaker == nil )
            strMaker =@"";
        [dict setObject:strMaker forKey:@"Maker"];
        
        NSString* strModel = [assetRepresentaion.metadata valueForKeyPath:@"{TIFF}.Model" ];
        if( strModel == nil )
            strModel =@"";
        [dict setObject:strModel forKey:@"Model"];
        
        [dict setObject:@"" forKey:@"Orientation"];
        [dict setObject:@"" forKey:@"Artist"];
        
        NSString* strExposureTIme = [self makeExposureString:[assetRepresentaion.metadata valueForKeyPath:@"{Exif}.ExposureTime" ]];
        [dict setObject:strExposureTIme forKey:@"ExposureTime"];
        
        NSString* strFNumber = [self makeFNumberString:[assetRepresentaion.metadata valueForKeyPath:@"{Exif}.FNumber" ]];
        [dict setObject:strFNumber forKey:@"FNumber"];
        
        NSString* strIso = [self makeISOString:[assetRepresentaion.metadata valueForKeyPath:@"{Exif}.ISOSpeedRatings" ]];
        [dict setObject:strIso forKey:@"ISO"];
        
        NSString* strDateTime = [assetRepresentaion.metadata valueForKeyPath:@"{Exif}.DateTimeOriginal" ];
        if( strDateTime == nil )
            strDateTime =@"";
        [dict setObject:strDateTime forKey:@"DateTimeOriginal"];
        
        [dict setObject:@"" forKey:@"ExposureCompensation"];
        [dict setObject:@"" forKey:@"MaxApertureValue"];
        
        NSString* strFlash = [self makeFlashString:[assetRepresentaion.metadata valueForKeyPath:@"{Exif}.Flash" ]];
        [dict setObject:strFlash forKey:@"Flash"];
        
        NSString* strFocalLength;
        NSNumber* focalLength = [assetRepresentaion.metadata valueForKeyPath:@"{Exif}.FocalLenIn35mmFilm" ];
        if(focalLength == nil)
        {
            strFocalLength = [self makeFocalLengthString:[assetRepresentaion.metadata valueForKeyPath:@"{Exif}.FocalLength" ]];
        }else{
            strFocalLength = [self makeFocalLengthString:focalLength];
        }
        [dict setObject:strFocalLength forKey:@"FocalLength"];
        
        [dict setObject:@"" forKey:@"LensInfo"];
        [dict setObject:@"" forKey:@"LensModel"];
        [dict setObject:@"" forKey:@"Lens"];
       
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
