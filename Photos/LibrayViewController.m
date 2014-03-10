//
//  LibrayViewController.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/08.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "LibrayViewController.h"
#import "AppDelegate.h"
#import "LibraryBaseCell.h"
#import "baseCollectionHeader.h"
#import "ItemThumbnailCollectionView.h"
#import "SingleViewController.h"


@interface LibrayViewController ()
@property (nonatomic, retain) AppDelegate* m_appDelegate;


@end

@implementation LibrayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)willGoSingleView:(NSNotification *)notification
{
    NSNumber* sectionIndex = [notification.userInfo objectForKey:@"SectionInex"];
    NSNumber *index = [notification.userInfo objectForKey:@"index"];
    NSInteger indexOf = [index intValue];
    NSInteger sectionIndexOf = [sectionIndex intValue];
    SingleViewController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SingleImageViewContoller"];
    viewController.sectionIndex = sectionIndexOf;
    viewController.index = indexOf;
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    self.m_appDelegate = appDelegate;
    
    NSInteger currentGroupIndex = [self.m_appDelegate.m_imageLibrary getCurrentGroupIndex];
    [self.m_appDelegate.m_imageLibrary createSectionDataAndSortByDateAtGroup:currentGroupIndex];
    NSString* libraryName = [self.m_appDelegate.m_imageLibrary getGroupNameAtIndex:[self.m_appDelegate.m_imageLibrary getCurrentGroupIndex]];
    
    CGRect rect = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.closeBaseCollectionView setFrame:rect];
    UICollectionViewFlowLayout *layout = (id) self.closeBaseCollectionView.collectionViewLayout;
    CGSize size = CGSizeMake(self.closeBaseCollectionView.frame.size.width, 200);
    layout.itemSize = size;
    
    //NSNotificationCenter *nc =[NSNotificationCenter defaultCenter];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willGoSingleView:) name:@"WillFullviewDisplay" object:nil];
    /*
    //[self.navigationController setNavigationBarHidden:NO animated:NO];
    //ラベルを生成
    UILabel* navigationTitle = [[UILabel alloc] init];
    //ラベルの大きさと位置を調整
    navigationTitle.frame = CGRectMake(0,10,320,25);
    navigationTitle.text = libraryName;  //テキスト名
    navigationTitle.font = [UIFont boldSystemFontOfSize:15.0];    //fontサイズ
    navigationTitle.backgroundColor = [UIColor clearColor];     //Labelの背景色
    navigationTitle.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];     //影の部分
    
    //文字揃え　（NSTextAlignmentLightとNSTextAligmentLeftもある）
    navigationTitle.textAlignment = NSTextAlignmentCenter;
    navigationTitle.textColor =[UIColor whiteColor];    //文字色
    
    //navigationItemのtitleViewをLabelに置き換える
    self.navigationItem.titleView = navigationTitle;
    */
    self.navigationItem.title = libraryName;
}

/* 横向き対応のため追加 */
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self.closeBaseCollectionView performBatchUpdates:nil completion:nil];
}



- (void)viewWillDisappear:(BOOL)animated
{
    [self.m_appDelegate.m_imageLibrary cleanupSectionsData];
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
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LibraryBaseCell* baseCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LibBaseCell" forIndexPath:indexPath];
    //ItemThumbnailCollectionView* currentCollectionView = [[ItemThumbnailCollectionView alloc] initWithIndex:indexPath.section];
    //currentCollectionView.delegate = baseCell;
    //currentCollectionView.dataSource = baseCell;
    NSInteger index = indexPath.section;
    //NSString* nameOfSection = [self.m_appDelegate.m_imageLibrary getSectionNames][index];
    NSArray* array = [self.m_appDelegate.m_imageLibrary getItemsInSectionByIndex:index];
    
    //currentCollectionView.items = array;
    baseCell.items = array;
    //baseCell.sectionName = nameOfSection;
    baseCell.sectionIndex = index;
    [baseCell.itemThumbnailCollection reloadData];
    return baseCell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    baseCollectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"baseCollectionHeader" forIndexPath:indexPath];
    
    NSArray* sectionLabels = [self.m_appDelegate.m_imageLibrary getSectionNames];
    headerView.sectionHeaderLabel.text = sectionLabels[indexPath.section];
    
    return headerView;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(self.closeBaseCollectionView.frame.size.width, 190);
    return size;
}
@end
