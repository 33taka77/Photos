//
//  PageRootViewController.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/04/03.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "PageRootViewController.h"
#import "AppDelegate.h"
#import "PageContentViewController.h"
#import "UIViewController+CWPopup.h"
#import "MetaInfoPopupViewController.h"

@interface PageRootViewController () <UIPageViewControllerDataSource>
@property (nonatomic, retain) AppDelegate* appDelegate;
@property (nonatomic, retain) UIPageViewController* pageViewController;
@property NSInteger numOfPages;
@property BOOL isDisplayMetaInfo;
@end

@implementation PageRootViewController

@synthesize sectionIndex;
@synthesize index;

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
    self.appDelegate = appDelegate;
    self.numOfPages =  [self.appDelegate.m_imageLibrary getNumOfImagesInSectionBySectonIndex:self.sectionIndex];
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    PageContentViewController* startViewController = [self viewControllerAtIndex:self.index];
    NSArray* viewControllers = @[startViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
    self.navigationItem.title = [NSString stringWithFormat: @"%d/%d",[self indexOfViewController:[self.pageViewController.viewControllers objectAtIndex:0]]+1,[self.appDelegate.m_imageLibrary getNumOfImagesInSectionBySectonIndex:self.sectionIndex]];
    UIBarButtonItem* button = [[UIBarButtonItem alloc]
                              initWithTitle:@"Info"
                              style:UIBarButtonItemStyleBordered
                              target:self
                              action:@selector(barButtonClicked:)];
    [button setImage:[UIImage imageNamed:@"info_24.png"]];
    self.navigationItem.rightBarButtonItem = button;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeMetaPopupView:) name:@"metaInfoPopupClosed" object:nil];

}

- (void)closeMetaPopupView:(NSNotification*)notification
{
    [self dismissPopupViewControllerAnimated:YES completion:^{
        NSLog(@"popup view closed");
    }];
    self.navigationController.navigationBar.hidden = NO;
    //self.isDisplayMetaInfo = NO;
}

- (void)barButtonClicked:(id)sender
{
    //self.isDisplayMetaInfo = YES;
    MetaInfoPopupViewController *samplePopupViewController = [[MetaInfoPopupViewController alloc] initWithNibName:@"metaInfoPopup" bundle:nil];
    [samplePopupViewController setUseBlurForPopup:YES];
    samplePopupViewController.sectionIndex = self.sectionIndex;
    samplePopupViewController.index = [self indexOfViewController:[self.pageViewController.viewControllers objectAtIndex:0]];
    [self presentPopupViewController:samplePopupViewController animated:YES completion:^(void) {
        NSLog(@"popup view presented");
    }];
    self.navigationController.navigationBar.hidden = YES;
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
//    if( self.isDisplayMetaInfo == YES )
//        return nil;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.sectionIndex], @"SectionIndex",[NSNumber numberWithInt:[self indexOfViewController:[self.pageViewController.viewControllers objectAtIndex:0]]], @"index", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"metaInfoPopupChanged" object:self userInfo:userInfo];
    
    self.navigationItem.title = [NSString stringWithFormat: @"%d/%d",[self indexOfViewController:[self.pageViewController.viewControllers objectAtIndex:0]]+1,[self.appDelegate.m_imageLibrary getNumOfImagesInSectionBySectonIndex:self.sectionIndex]];

    NSInteger indexOfPage = ((PageContentViewController*)viewController).pageIndex;
 
    if( (indexOfPage == 0) || (indexOfPage == NSNotFound) )
    {
        return nil;
    }
    indexOfPage --;

    return [self viewControllerAtIndex:indexOfPage];
}
- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
//    if( self.isDisplayMetaInfo == YES )
//        return nil;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:self.sectionIndex], @"SectionIndex",[NSNumber numberWithInt:[self indexOfViewController:[self.pageViewController.viewControllers objectAtIndex:0]]], @"index", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"metaInfoPopupChanged" object:self userInfo:userInfo];

    NSInteger indexOfPage = ((PageContentViewController*)viewController).pageIndex;
    if( indexOfPage == NSNotFound ){
        return nil;
    }
    indexOfPage ++;
    self.navigationItem.title = [NSString stringWithFormat: @"%d/%d",[self indexOfViewController:[self.pageViewController.viewControllers objectAtIndex:0]]+1,[self.appDelegate.m_imageLibrary getNumOfImagesInSectionBySectonIndex:self.sectionIndex]];

    if( indexOfPage >= self.numOfPages ){
        return nil;
    }

    return [self viewControllerAtIndex:indexOfPage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)indexOfPage{
    if( ( self.numOfPages == 0 ) || ( indexOfPage >= self.numOfPages ) )
    {
        return nil;
    }
    
    PageContentViewController* pageviewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageContentViewController"];
    //UIImage* image = [self.appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:indexOfPage];
    //UIImage* image = [UIImage imageNamed:@"1.jpg"];
    pageviewController.sectionIndex = self.sectionIndex;
    pageviewController.pageIndex = indexOfPage;
    

    return pageviewController;
}

- (NSUInteger)indexOfViewController:(PageContentViewController *)viewController
{
    return viewController.pageIndex;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
