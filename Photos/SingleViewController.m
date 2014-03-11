//
//  SingleViewController.m
//  Photos
//
//  Created by 相澤 隆志 on 2014/03/09.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "SingleViewController.h"
#import "AppDelegate.h"

@interface SingleViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *fullImageView;
@property (nonatomic, retain) AppDelegate* m_appDelegate;


@end

@implementation SingleViewController

@synthesize index;
@synthesize sectionIndex;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
 //   sectionIndex = 0;
 //   index = 0;
    self.fullImageView.image = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    AppDelegate* appDelegate = [[UIApplication sharedApplication] delegate];
    self.m_appDelegate = appDelegate;
    NSInteger section = self.sectionIndex;
    NSInteger index = self.index;
    NSLog(@"SingleView section:%ld index:%ld",(long)section, (long)index);
    UIImage* image = [self.m_appDelegate.m_imageLibrary getFullSreenViewImageAtSectionByIndex:self.sectionIndex index:self.index];
    self.fullImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.fullImageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
