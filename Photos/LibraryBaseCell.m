//
//  LibraryBaseCell.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/08.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "LibraryBaseCell.h"
#import "ItemThumbnailCell.h"
#import "AppDelegate.h"
#import "ItemThumbnailCollectionView.h"
#import "ItemThumbnailCell.h"

#define kBaseCellHeight     (170)

@interface LibraryBaseCell ()
@property (nonatomic, retain) AppDelegate* m_appDelegate;
@end

@implementation LibraryBaseCell

@synthesize items;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if( self )
    {
        AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
        self.m_appDelegate = appDelegate;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotateView:) name:@"WillRotateView" object:nil];

    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)willRotateView:(NSNotification *)notification
{
    [self.itemThumbnailCollection reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    /*
    //NSInteger currentIndex = [self.m_appDelegate.m_imageLibrary getCurrentGroupIndex];
    //NSArray* names = [self.m_appDelegate.m_imageLibrary getSectionNames];
    //NSString* name = names[currentIndex];
    NSArray* array = [self.m_appDelegate.m_imageLibrary getSectionNames];
    ItemThumbnailCollectionView* thumbnaulCollection = (ItemThumbnailCollectionView*)collectionView;
    NSInteger index = thumbnaulCollection.identifier;

    NSString* sectionTitle = array[index-1];
    NSInteger numOfImage = [self.m_appDelegate.m_imageLibrary getNumOfImagesInSection:sectionTitle];
    
    
     //SectionData* sectionData = self.dateEntry[section];
     //NSInteger num = sectionData.items.count;
     //return num;
     */
    //return 5;
    NSInteger numOfImage = self.items.count;
    return numOfImage;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    ItemThumbnailCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemThumbnailCell" forIndexPath:indexPath];
    
    UIImage* thumbnailData = [self.m_appDelegate.m_imageLibrary getThumbnailAtSectionByIndex:self.sectionIndex index:indexPath.row];
    cell.thumbnailImageView.image = thumbnailData;
    //cell.thumbnailImageView.image = nil;
    return cell;
}

/*
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(150, 150);
    
    UIImage* thumbnailData = [self.m_appDelegate.m_imageLibrary getThumbnailAtSectionByIndex:self.sectionIndex index:indexPath.row];
    
    float width = thumbnailData.size.width;
    float height = thumbnailData.size.height;
    if( height > kBaseCellHeight )
    {
        height = kBaseCellHeight;
        width = width * kBaseCellHeight/thumbnailData.size.height;
    }
    CGSize retval = thumbnailData.size.width > 0 ? CGSizeMake(width, height): CGSizeMake(100, 100);
    retval.height += 15; retval.width += 15;
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(50, 20, 50, 20);
}
*/

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //NSInteger currentIndex = indexPath.row;
    //NSArray* names = [self.m_appDelegate.m_imageLibrary getSectionNames];
    //NSString* sectionName = names[currentIndex];
    NSInteger row = indexPath.row;
    NSInteger section = self.sectionIndex;
    NSLog(@"didSelectItem section:%ld index:%ld", (long)section, (long)row);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:section], @"SectionIndex",[NSNumber numberWithInt:row], @"index", nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"WillFullviewDisplay" object:self userInfo:userInfo];
    
}


@end
