//
//  ImageLibrary.h
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/06.
//  Copyright (c) 2014年 Aizawa Takashi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kImageLibraryTypeLocal      (1)
#define kImageLibraryTypeFlickr     (2)
#define kImageLibraryTypeFacebook   (4)

@protocol ImageLibraryDelegate

- (void)updateView;

@end



@interface ImageLibrary : NSObject

/* 
 This delegate is called when view is updated.
 */
@property id < ImageLibraryDelegate > delegate;

/*
 Get ImageLibrary instance by singleton pattern.
*/
+ (ImageLibrary*)sharedLibrary:(NSUInteger)type;

/*
 Initialize the library.
 */
-(void)initializeLibrary;

/*
 Set the type of the target source of the images.
*/
- (void)setWithType:(NSUInteger)type;

/*
 Create the image datas and sort the data by the date.
*/
//- (void)createSectionDataAndSortByDate;

- (void)refleshImages;

- (void)deleteImages;

- (void)createSectionDataAndSortByDateAtGroup:(NSInteger)GroupIndex;

- (void)setCurrentGroup:(NSInteger)index;

-(NSInteger)getCurrentGroupIndex;

//-(void)createSectionEntries;

- (NSInteger)getGroupCount;

- (NSArray*)getGroupNames;

- (NSInteger)getSectionCount;

//- (NSArray*)getItemsInSection:(NSString*)sectionName;

- (NSArray*)getItemsInSectionByIndex:(NSInteger)sectionIndex;

- (NSArray*)getSectionNames;

- (NSString*)getGroupNameAtIndex:(NSInteger)index;

//- (NSString*)getSectonNameAtGroup:(NSString*)groupName index:(NSInteger)index;

- (NSInteger)getNumOfImagesInSection:(NSString*)sectionName;

- (NSInteger)getNumOfImagesInSectionBySectonIndex:(NSInteger)sectionIndex;


- (NSInteger)getNumOfImagesInGroup:(NSString*)groupName;

//- (UIImage*)getThumbnailAtGroupName:(NSString*)groupName index:(NSInteger)index;

- (UIImage*)getThumbnailAtGroupByIndex:(NSInteger)groupIndex index:(NSInteger)index;

- (UIImage*)getThumbnailAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index;

- (UIImage*)getAspectThumbnailAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index;

//- (UIImage*)getThumbnailAtSectionName:(NSString*)sectionName index:(NSInteger)index;

//- (UIImage*)getThumbnailAtSectionName:(NSString*)sectionName URL:(NSURL*)url;

//- (UIImage*)getFullViewImageAtSectionName:(NSString*)sectionName index:(NSInteger)index;

- (UIImage*)getFullViewImageAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index;

- (UIImage*)getFullSreenViewImageAtSectionByIndex:(NSInteger)sectionIndex index:(NSInteger)index;

- (void)cleanupSectionsData;

- (NSDictionary*)getMetaDataBySectionIndex:(NSInteger)sectionIndex index:(NSInteger)index;



@end
