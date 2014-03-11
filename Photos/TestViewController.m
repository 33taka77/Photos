//
//  TestViewController.m
//  Photos
//
//  Created by Aizawa Takashi on 2014/03/11.
//  Copyright (c) 2014年 相澤 隆志. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()
- (IBAction)CloseButtonClicked:(id)sender;

@end

@implementation TestViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)CloseButtonClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
