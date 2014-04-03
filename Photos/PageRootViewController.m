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

@interface PageRootViewController () <UIPageViewControllerDataSource>
@property (nonatomic, retain) AppDelegate* appDelegate;
@property (nonatomic, retain) UIPageViewController* pageViewController;
@property NSInteger numOfPages;
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
    PageContentViewController* startViewController = [self viewControllerAtIndex:0];
    NSArray* viewControllers = @[startViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (UIViewController*)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
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
    NSInteger indexOfPage = ((PageContentViewController*)viewController).pageIndex;
    if( indexOfPage == NSNotFound ){
        return nil;
    }
    indexOfPage ++;
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
    UIImage* image = [self.appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:indexOfPage];
    pageviewController.imageView.image = image;
    pageviewController.pageIndex = indexOfPage;
    return pageviewController;
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
