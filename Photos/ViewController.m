//
//  ViewController.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/06.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "GroupCell.h"
#import "ImageLibrary.h"

@interface ViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) AppDelegate* m_appDelegate;
@property (weak, nonatomic) IBOutlet UICollectionView *groupCollectionView;
@property (weak, nonatomic) IBOutlet UIToolbar *groupToolBar;
- (IBAction)applicationSettingButtonClicked:(id)sender;

- (IBAction)abortButtonClicked:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    self.m_appDelegate = appDelegate;
    //[self.m_appDelegate.m_imageLibrary createSectionDataAndSortByDate];
    //[self.groupCollectionView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:@"BaseCollectionInit" object:nil];
    
}

- (void)updateData:(NSNotification *)notification
{
    [self.groupCollectionView reloadData];
    NSLog(@"reload is called");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger num = [self.m_appDelegate.m_imageLibrary getGroupCount];
    return num;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GroupCell" forIndexPath:indexPath];
    NSString* name = [self.m_appDelegate.m_imageLibrary getGroupNameAtIndex:indexPath.row];
    cell.groupName.text = name;
    NSInteger count =  [self.m_appDelegate.m_imageLibrary getNumOfImagesInGroup:name];
    NSString* num = [NSString stringWithFormat:@"(%d)",count ];
    cell.groupCont.text = num;

    if( count > 2 )
    {
        cell.groupImage1.image = [self.m_appDelegate.m_imageLibrary getThumbnailAtGroupName:name index:2];
        //CGFloat angle = 20.0 * M_PI / 180.0;
        //cell.groupImage1.transform = CGAffineTransformMakeRotation(angle);
        //cell.groupImage1.transform = CGAffineTransformMakeScale( 1.3, 1.3);
        //cell.groupImagebase1.transform = CGAffineTransformMakeRotation(angle);
        //cell.groupImagebase1.transform = CGAffineTransformMakeScale( 1.3, 1.3);
        cell.groupImage1.transform = CGAffineTransformMakeTranslation(-15, -15);
        cell.groupImagebase1.transform = CGAffineTransformMakeTranslation(-15, -15);
    }
    if( count > 1 )
    {
        cell.groupImage2.image = [self.m_appDelegate.m_imageLibrary getThumbnailAtGroupName:name index:1];
        //CGFloat angle = 10.0 * M_PI / 180.0;
        //cell.groupImage2.transform = CGAffineTransformMakeRotation(angle);
        //cell.groupImage2.transform = CGAffineTransformMakeScale( 1.2, 1.2);
        //cell.groupImagebase2.transform = CGAffineTransformMakeRotation(angle);
        //cell.groupImagebase2.transform = CGAffineTransformMakeScale( 1.3, 1.3);
   }
    if( count > 0 )
    {
        cell.groupImage3.image = [self.m_appDelegate.m_imageLibrary getThumbnailAtGroupName:name index:0];
        //CGFloat angle = 30.0 * M_PI / 180.0;
        //CGAffineTransform t1 = CGAffineTransformMakeRotation(angle);
        //CGAffineTransform t2 = CGAffineTransformScale(t1,1.2,1.2);
        //NSInteger newWidth = cell.groupImage3.frame.size.width* 1.2;
        //NSInteger newheight = cell.groupImage3.frame.size.height* 1.2;
        //NSInteger deff = newheight - cell.groupImage3.frame.size.height;
        
        //CGRect rect = CGRectMake(cell.groupImage3.frame.origin.x -deff/2, cell.groupImage3.frame.origin.y -deff/2, newWidth, newheight);
        cell.groupImage3.transform = CGAffineTransformMakeTranslation(15, 15);
        cell.groupImagebase3.transform = CGAffineTransformMakeTranslation(15, 15);
        //cell.groupImage3.transform = t2;//CGAffineTransformMakeRotation(angle);
        //cell.groupImage3.transform = CGAffineTransformMakeScale( 1.2, 1.2);
        //cell.groupImage3.frame = rect;
        //cell.groupImage3.transform = t2;//CGAffineTransformMakeRotation(angle);

    }
    return cell;
}

- (void)collectionView:(UICollectionView*)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger currentIndex = indexPath.row;
    [self.m_appDelegate.m_imageLibrary setCurrentGroup:currentIndex];
    
    UITabBarController* viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LibararyViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
    
}
- (IBAction)applicationSettingButtonClicked:(id)sender {
}
- (IBAction)abortButtonClicked:(id)sender {
}
@end
