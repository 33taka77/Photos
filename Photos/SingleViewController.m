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
@synthesize sectionName;

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
    
    UIImage* image = [self.m_appDelegate.m_imageLibrary getFullViewImageAtSectionName:self.sectionName index:self.index];
    self.fullImageView.image = image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
