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
- (void) createSectionDataAndSortByDate;

- (NSInteger)getSectionCount;

- (NSArray*)getSectionNames;

- (NSInteger)getNumOfImagesInSection:(NSString*)sectionName;

- (UIImage*)getThumbnailAtSectionName:(NSString*)sectionName index:(NSInteger)index;

- (UIImage*)getFullViewImageAtSectionName:(NSString*)sectionName index:(NSInteger)index;

@end
