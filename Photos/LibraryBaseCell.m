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


@interface LibraryBaseCell ()
@property (nonatomic, retain) AppDelegate* m_appDelegate;
@end

@implementation LibraryBaseCell

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

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    //NSInteger currentIndex = [self.m_appDelegate.m_imageLibrary getCurrentGroupIndex];
    //NSArray* names = [self.m_appDelegate.m_imageLibrary getSectionNames];
    //NSString* name = names[currentIndex];
    NSArray* array = [self.m_appDelegate.m_imageLibrary getSectionNames];
    ItemThumbnailCollectionView* thumbnaulCollection = (ItemThumbnailCollectionView*)collectionView;
    NSInteger index = thumbnaulCollection.identifier;

    NSString* sectionTitle = array[index-1];
    NSInteger numOfImage = [self.m_appDelegate.m_imageLibrary getNumOfImagesInSection:sectionTitle];
    
    /*
     SectionData* sectionData = self.dateEntry[section];
     NSInteger num = sectionData.items.count;
     return num;
     */
    return numOfImage;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ItemThumbnailCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ItemThumbnailCell" forIndexPath:indexPath];
    cell.backgroundView.backgroundColor = [UIColor yellowColor];
    return cell;
}

@end
