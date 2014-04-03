//
//  PageContentViewController.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/04/03.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "PageContentViewController.h"
#import "AppDelegate.h"

@interface PageContentViewController ()
@property (nonatomic, retain) AppDelegate* appDelegate;

@end

@implementation PageContentViewController

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
     //UIImage* image = [UIImage imageNamed:@"1.jpg"];
    UIImage* image = [self.appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:self.pageIndex];
    self.imageView.image =image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
