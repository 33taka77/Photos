//
//  ImageSelectViewController.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/11.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "ImageSelectViewController.h"
#import "AppDelegate.h"
#import "ImageSelectCollectionHeader.h"
#import "SelectCollectionCell.h"

#define kSelectViewCellHeight  (100)

@interface ImageSelectViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, retain) AppDelegate* m_appDelegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)backToBrowseViewButtonIsClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *imageSelectCollectionView;

@end

@implementation ImageSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    self.m_appDelegate = appDelegate;
    NSString* libraryName = [self.m_appDelegate.m_imageLibrary getGroupNameAtIndex:[self.m_appDelegate.m_imageLibrary getCurrentGroupIndex]];
    self.titleLabel.text = libraryName;
    [self.imageSelectCollectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger sections = [self.m_appDelegate.m_imageLibrary getSectionCount];
    return sections;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger row = [self.m_appDelegate.m_imageLibrary getNumOfImagesInSectionBySectonIndex:section];
    return row;
}
- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SelectCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectCollectionCell" forIndexPath:indexPath];
    UIImage* thumbnailData = [self.m_appDelegate.m_imageLibrary getAspectThumbnailAtSectionByIndex:indexPath.section index:indexPath.row];
    cell.selectThumbnailView.image = thumbnailData;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage* thumbnailData = [self.m_appDelegate.m_imageLibrary getAspectThumbnailAtSectionByIndex:indexPath.section index:indexPath.row];
    float width = thumbnailData.size.width;
    float height = thumbnailData.size.height;
    /*
    if( height > kSelectViewCellHeight )
    {
        height = kSelectViewCellHeight;
        width = width * kSelectViewCellHeight/thumbnailData.size.height;
    }
    */
    CGSize retval = thumbnailData.size.width > 0 ? CGSizeMake(width/3, height/3): CGSizeMake(50, 50);
    //retval.height += 15; retval.width += 15;
    return retval;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ImageSelectCollectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ImageSelectCollectionHeader" forIndexPath:indexPath];
    
    NSArray* sectionLabels = [self.m_appDelegate.m_imageLibrary getSectionNames];
    headerView.selectCollectionHeaderLabel.text = sectionLabels[indexPath.section];
    return headerView;
}

- (IBAction)backToBrowseViewButtonIsClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
